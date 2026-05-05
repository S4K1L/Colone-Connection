// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_extension/model/map_point_model.dart';
import 'package:flutter_extension/model/map_search_models.dart';
import 'package:flutter_extension/model/sales_team_report_details_model.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/util/api_constant.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/search_filter_chips_row.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

enum MapSearchFilterKind { all, colonies, customers }

class HomeController extends GetxController {
  static const LatLng center = LatLng(23.7806, 90.4056);
  final TextEditingController searchController = TextEditingController();

  final List<MapPointModel> points = <MapPointModel>[];
  final List<SearchCustomerResult> _customerPool = <SearchCustomerResult>[];

  final Set<Marker> markers = <Marker>{};
  BitmapDescriptor? _greenMarkerIcon;
  BitmapDescriptor? _redMarkerIcon;
  MapPointModel? selectedPoint;
  bool isSearchOpen = false;
  MapSearchFilterKind searchFilter = MapSearchFilterKind.all;
  bool isLoading = false;
  String? errorMessage;

  bool isColonyReportDetailsLoading = false;
  String? colonyReportDetailsErrorMessage;
  SalesTeamReportDetailsModel? colonyReportDetails;

  static const List<String> _districts = <String>[
    'North District',
    'East Zone',
    'West Block',
    'Central Area',
  ];

  static const List<String> _visitLabels = <String>[
    'Yesterday',
    '2 days ago',
    'Last week',
    'Yesterday',
  ];

  bool get hasMapsKey => (dotenv.env['GOOGLE_API_KEY'] ?? '').isNotEmpty;
  String get todayLabel => _formatLongDate(DateTime.now());

  /// True when the inline search has text: show full-screen search UI.
  bool get showSearchResultsLayer =>
      isSearchOpen && searchController.text.trim().isNotEmpty;

  String get searchQueryDisplay => searchController.text.trim();

  List<SearchColonyResult> get _searchColonyPool {
    final List<SearchColonyResult> list = <SearchColonyResult>[
      for (int i = 0; i < points.length; i++)
        SearchColonyResult(
          id: points[i].id,
          name: points[i].name,
          district: _districts[i % _districts.length],
          customers: points[i].customers,
          lastVisitLabel: _visitLabels[i % _visitLabels.length],
        ),
      const SearchColonyResult(
        id: 'gv',
        name: 'Green Valley Colony',
        district: 'North District',
        customers: 12,
        lastVisitLabel: 'Yesterday',
      ),
    ];
    return list;
  }

  bool _matches(String value, String query) {
    if (query.isEmpty) {
      return false;
    }
    return value.toLowerCase().contains(query.toLowerCase());
  }

  List<SearchColonyResult> get filteredColonyResults {
    final String q = searchController.text.trim();
    if (q.isEmpty) {
      return <SearchColonyResult>[];
    }
    return _searchColonyPool
        .where(
          (SearchColonyResult c) =>
              _matches(c.name, q) || _matches(c.district, q),
        )
        .toList();
  }

  List<SearchCustomerResult> get filteredCustomerResults {
    final String q = searchController.text.trim();
    if (q.isEmpty) {
      return <SearchCustomerResult>[];
    }
    return _customerPool
        .where(
          (SearchCustomerResult c) =>
              _matches(c.colonyName, q) ||
              _matches(c.role, q) ||
              _matches(c.phone, q) ||
              _matches(c.email, q) ||
              _matches(c.initials, q),
        )
        .toList();
  }

  List<SearchColonyResult> get visibleColonyResults {
    if (searchFilter == MapSearchFilterKind.customers) {
      return <SearchColonyResult>[];
    }
    return filteredColonyResults;
  }

  List<SearchCustomerResult> get visibleCustomerResults {
    if (searchFilter == MapSearchFilterKind.colonies) {
      return <SearchCustomerResult>[];
    }
    return filteredCustomerResults;
  }

  bool get hasSearchMatches =>
      visibleColonyResults.isNotEmpty || visibleCustomerResults.isNotEmpty;

  void setSearchFilter(MapSearchFilterKind kind) {
    if (searchFilter == kind) {
      return;
    }
    searchFilter = kind;
    update();
  }

  List<SearchFilterChipData> buildSearchFilterChips() {
    final int allCount =
        filteredColonyResults.length + filteredCustomerResults.length;
    final int colCount = filteredColonyResults.length;
    final int custCount = filteredCustomerResults.length;
    return <SearchFilterChipData>[
      SearchFilterChipData(
        id: 'all',
        label: 'All ($allCount)',
        selected: searchFilter == MapSearchFilterKind.all,
        onTap: () => setSearchFilter(MapSearchFilterKind.all),
      ),
      SearchFilterChipData(
        id: 'colonies',
        label: 'Colony ($colCount)',
        selected: searchFilter == MapSearchFilterKind.colonies,
        onTap: () => setSearchFilter(MapSearchFilterKind.colonies),
      ),
      SearchFilterChipData(
        id: 'customers',
        label: 'Customers ($custCount)',
        onTap: () => setSearchFilter(MapSearchFilterKind.customers),
        selected: searchFilter == MapSearchFilterKind.customers,
      ),
    ];
  }

  void _onSearchTextChanged() {
    update();
  }

  int get totalVisited => points.where((MapPointModel e) => e.isVisited).length;
  int get todayColonies => points.length;
  int get totalCustomers =>
      points.fold<int>(0, (int total, MapPointModel e) => total + e.customers);
  int get totalVisits =>
      points.fold<int>(0, (int total, MapPointModel e) => total + e.visits);

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchTextChanged);
    getSalesTeamReport();
  }

  Future<void> getSalesTeamReport() async {
    isLoading = true;
    errorMessage = null;
    update();
    try {
      final String date = _formatDateForApi(DateTime.now());
      final response = await ApiService().get(
        ApiConstant.SALES_TEAM_REPORT,
        queryParams: <String, dynamic>{'date': date},
        authReq: true,
      );
      final dynamic raw = response.data;
      final List<dynamic> dataList = raw is Map<String, dynamic>
          ? (raw['data'] as List<dynamic>? ?? <dynamic>[])
          : <dynamic>[];

      points.clear();
      _customerPool.clear();

      for (final dynamic item in dataList) {
        if (item is! Map<String, dynamic>) continue;

        final Map<String, dynamic> colony =
            (item['colony'] as Map<String, dynamic>? ?? <String, dynamic>{});
        // This API uses an `id` for the report row, and another `colony.id` inside the payload.
        // The "details" endpoint should be called using the report row `id`.
        final String reportId = (item['id'] ?? '').toString();
        final String colonyName = (colony['name'] ?? '').toString();
        final String region = (colony['region'] ?? '').toString();
        final double lat = _toDouble(colony['latitude']);
        final double lng = _toDouble(colony['longitude']);
        if (reportId.isEmpty || colonyName.isEmpty) continue;

        final int completedCount = _toInt(item['completed_count']);
        final int totalCount = _toInt(item['total_customers']);
        final bool visited = (item['is_visited'] == true);

        points.add(
          MapPointModel(
            id: reportId,
            name: colonyName,
            region: region.isEmpty ? 'North District' : region,
            visits: completedCount,
            customers: totalCount,
            isVisited: visited,
            position: LatLng(lat, lng),
          ),
        );

        final List<dynamic> pendingCustomers =
            item['pending_customers'] as List<dynamic>? ?? <dynamic>[];
        final List<dynamic> completedCustomers =
            item['completed_customers'] as List<dynamic>? ?? <dynamic>[];
        _customerPool.addAll(
          _mapCustomers(
            colonyName: colonyName,
            pendingCustomers: pendingCustomers,
            completedCustomers: completedCustomers,
          ),
        );
      }

      await buildCustomMarkers();
    } catch (e) {
      errorMessage = e.toString();
      showCustomSnackBar(
        errorMessage ?? 'Failed to load report data.',
        getXSnackBar: true,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchColonyReportDetails(String reportId) async {
    if (reportId.isEmpty) return;
    isColonyReportDetailsLoading = true;
    colonyReportDetailsErrorMessage = null;
    colonyReportDetails = null;
    update();

    try {
      final response = await ApiService().get(
        '${ApiConstant.SALES_TEAM_REPORT}$reportId',
        authReq: true,
      );

      final dynamic raw = response.data;
      final dynamic data = raw is Map<String, dynamic> ? raw['data'] : null;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response: missing `data`.');
      }

      colonyReportDetails = SalesTeamReportDetailsModel.fromJson(data);

      update();
    } catch (e) {
      colonyReportDetailsErrorMessage = e.toString();
      showCustomSnackBar(
        colonyReportDetailsErrorMessage ?? 'Failed to load details.',
        getXSnackBar: true,
      );
      update();
    } finally {
      isColonyReportDetailsLoading = false;
      update();
    }
  }

  Future<void> buildCustomMarkers() async {
    _greenMarkerIcon = await _createCircleMarker(AppColors.green500);
    _redMarkerIcon = await _createCircleMarker(AppColors.errorColor);

    final Set<Marker> generated = <Marker>{};
    for (final MapPointModel point in points) {
      generated.add(
        Marker(
          markerId: MarkerId(point.id),
          position: point.position,
          icon: point.isVisited ? _greenMarkerIcon! : _redMarkerIcon!,
          onTap: () => onMarkerTap(point),
        ),
      );
    }

    markers
      ..clear()
      ..addAll(generated);
    update();
  }

  List<SearchCustomerResult> _mapCustomers({
    required String colonyName,
    required List<dynamic> pendingCustomers,
    required List<dynamic> completedCustomers,
  }) {
    final List<SearchCustomerResult> result = <SearchCustomerResult>[];
    final List<dynamic> customers = <dynamic>[
      ...pendingCustomers,
      ...completedCustomers,
    ];
    for (final dynamic customer in customers) {
      if (customer is! Map<String, dynamic>) continue;
      final String ownerName = (customer['owner_name'] ?? '').toString().trim();
      final String companyName = (customer['company_name'] ?? '')
          .toString()
          .trim();
      result.add(
        SearchCustomerResult(
          id: (customer['id'] ?? '').toString(),
          colonyName: colonyName,
          role: companyName.isEmpty ? 'Customer' : companyName,
          initials: _initialsFromName(ownerName),
          phone: (customer['phone'] ?? '').toString(),
          email: (customer['email'] ?? '').toString(),
        ),
      );
    }
    return result;
  }

  String _initialsFromName(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDateForApi(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatLongDate(DateTime date) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void onMarkerTap(MapPointModel point) {
    selectedPoint = point;
    update();
  }

  void clearSelectedPoint() {
    if (selectedPoint == null) return;
    selectedPoint = null;
    update();
  }

  void openSearch() {
    isSearchOpen = true;
    update();
  }

  void closeSearch() {
    if (!isSearchOpen) {
      return;
    }
    isSearchOpen = false;
    searchFilter = MapSearchFilterKind.all;
    searchController.clear();
    update();
  }

  Future<BitmapDescriptor> _createCircleMarker(Color color) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const double size = 120;
    const Offset centerOffset = Offset(size / 2, size / 2);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: .24)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);
    // Draw a nice soft shadow
    canvas.drawCircle(centerOffset.translate(0, 5), 45, shadowPaint);

    final Paint whiteRing = Paint()..color = AppColors.white;
    canvas.drawCircle(centerOffset, 42, whiteRing);

    final Paint fillPaint = Paint()..color = color;
    canvas.drawCircle(centerOffset, 34, fillPaint);

    final ui.Image image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    super.onClose();
  }
}

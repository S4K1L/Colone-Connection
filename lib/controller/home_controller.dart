import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_extension/data/model/map_point_model.dart';
import 'package:flutter_extension/data/model/map_search_models.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/search_filter_chips_row.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

enum MapSearchFilterKind { all, colonies, customers }

class HomeController extends GetxController {
  static const LatLng center = LatLng(23.7808, 90.2792);
  final TextEditingController searchController = TextEditingController();

  final List<MapPointModel> points = <MapPointModel>[
    const MapPointModel(
      id: 'm1',
      name: 'Blue Ridge Estate',
      visits: 15,
      customers: 58,
      isVisited: true,
      position: LatLng(23.7814, 90.2700),
    ),
    const MapPointModel(
      id: 'm2',
      name: 'Mirpur Colony',
      visits: 8,
      customers: 40,
      isVisited: false,
      position: LatLng(23.7789, 90.2860),
    ),
    const MapPointModel(
      id: 'm3',
      name: 'Savar North',
      visits: 11,
      customers: 36,
      isVisited: true,
      position: LatLng(23.7753, 90.2790),
    ),
    const MapPointModel(
      id: 'm4',
      name: 'Sheorapara Point',
      visits: 5,
      customers: 20,
      isVisited: false,
      position: LatLng(23.7855, 90.2850),
    ),
  ];

  final Set<Marker> markers = <Marker>{};
  BitmapDescriptor? _greenMarkerIcon;
  BitmapDescriptor? _redMarkerIcon;
  MapPointModel? selectedPoint;
  bool isSearchOpen = false;
  MapSearchFilterKind searchFilter = MapSearchFilterKind.all;

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

  static const List<SearchCustomerResult> _customerPool =
      <SearchCustomerResult>[
    SearchCustomerResult(
      id: 'c1',
      colonyName: 'Green Valley Colony',
      role: 'Shop Keeper',
      initials: 'DK',
      phone: '+1 (555) 567-8901',
      email: 'dkumar@primesol.com',
    ),
    SearchCustomerResult(
      id: 'c2',
      colonyName: 'Mirpur Colony',
      role: 'Owner',
      initials: 'AB',
      phone: '+880 1711 000000',
      email: 'owner@example.com',
    ),
  ];

  bool get hasMapsKey => (dotenv.env['GOOGLE_API_KEY'] ?? '').isNotEmpty;

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
        label: 'Colonies ($colCount)',
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
  int get totalVisits => points.fold<int>(0, (int total, MapPointModel e) => total + e.visits);

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchTextChanged);
    buildCustomMarkers();
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
    const double size = 96;
    const Offset centerOffset = Offset(size / 2, size / 2);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.16)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawCircle(centerOffset.translate(0, 7), 24, shadowPaint);

    final Paint whiteRing = Paint()..color = AppColors.white;
    canvas.drawCircle(centerOffset, 21.5, whiteRing);

    final Paint fillPaint = Paint()..color = color;
    canvas.drawCircle(centerOffset, 16.5, fillPaint);

    final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    super.onClose();
  }
}

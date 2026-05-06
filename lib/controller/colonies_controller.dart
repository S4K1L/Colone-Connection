import 'package:flutter/material.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/model/colony_list_item_model.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/util/api_constant.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
import 'package:get/get.dart';

enum ColonyVisitFilter { all, visited, notVisited }

class ColoniesController extends GetxController {
  static const int totalColonies = 56;

  ColonyVisitFilter filter = ColonyVisitFilter.all;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  String? errorMessage;

  final List<ColonyListItem> _items = <ColonyListItem>[];

  @override
  void onInit() {
    super.onInit();
    getColoniesReport();
  }

  Future<void> getColoniesReport() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final String dateStr = _formatDateForApi(selectedDate);
      final response = await ApiService().get(
        ApiConstant.SALES_TEAM_REPORT,
        queryParams: <String, dynamic>{'date': dateStr},
        authReq: true,
      );

      final dynamic raw = response.data;
      final List<dynamic> dataList = raw is Map<String, dynamic>
          ? (raw['data'] as List<dynamic>? ?? <dynamic>[])
          : <dynamic>[];

      _items.clear();
      for (final dynamic item in dataList) {
        if (item is! Map<String, dynamic>) continue;

        final Map<String, dynamic> colony =
            (item['colony'] as Map<String, dynamic>? ?? <String, dynamic>{});
        
        final String reportId = (item['id'] ?? '').toString();
        final String colonyId = (colony['id'] ?? '').toString();
        final String colonyName = (colony['name'] ?? '').toString();
        final String region = (colony['region'] ?? '').toString();
        if (reportId.isEmpty || colonyName.isEmpty) continue;

        final int completedCount = _toInt(item['completed_count']);
        final int totalCount = _toInt(item['total_customers']);
        final bool visited = (item['is_visited'] == true);

        _items.add(
          ColonyListItem(
            id: reportId,
            colonyId: colonyId,
            name: colonyName,
            area: region.isEmpty ? 'North District' : region,
            isVisited: visited,
            statusDateLabel: _formatDate(selectedDate),
            customers: totalCount,
            visitedCount: completedCount,
            lastVisitLabel: 'Recently', // Simplified or logic from backend if exists
          ),
        );
      }
    } catch (e) {
      errorMessage = e.toString();
      showCustomSnackBar(errorMessage ?? 'Failed to load colonies.', getXSnackBar: true);
    } finally {
      isLoading = false;
      update();
    }
  }

  List<ColonyListItem> get visibleColonies {
    switch (filter) {
      case ColonyVisitFilter.all:
        return List<ColonyListItem>.from(_items);
      case ColonyVisitFilter.visited:
        return _items.where((ColonyListItem e) => e.isVisited).toList();
      case ColonyVisitFilter.notVisited:
        return _items.where((ColonyListItem e) => !e.isVisited).toList();
    }
  }

  void setFilter(ColonyVisitFilter value) {
    filter = value;
    update();
  }

  Future<void> pickDate() async {
    final BuildContext? ctx = Get.context;
    if (ctx == null) return;
    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      selectedDate = picked;
      getColoniesReport();
    }
  }

  void onAddColony() {
    Get.toNamed(AppRoutes.addColony);
  }

  void onSearchColonies() {
    Get.snackbar('Colonies', 'Search (demo).');
  }

  void onViewDetails(ColonyListItem item) {
    Get.toNamed(
      AppRoutes.colonyCustomers,
      arguments: ColonyCustomersArgs(
        colonyId: item.colonyId,
        reportId: item.id,
        colonyName: item.name,
        totalCustomers: item.customers,
        colonyArea: item.area,
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDateForApi(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String get formattedSelectedDate => _formatDate(selectedDate);

  static String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }
}

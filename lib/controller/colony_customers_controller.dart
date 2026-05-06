import 'package:flutter/foundation.dart';
import 'package:flutter_extension/model/colony_customer_model.dart';
import 'package:flutter_extension/model/sales_team_report_details_model.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
import 'package:get/get.dart';

enum ColonyCustomerListFilter { all, visited, overdue }

class ColonyCustomersController extends GetxController {
  ColonyCustomersController({required this.args});

  final ColonyCustomersArgs args;
  final ApiService apiService = ApiService();

  ColonyCustomerListFilter filter = ColonyCustomerListFilter.all;
  bool isLoading = false;

  final List<ColonyCustomerItem> _items = <ColonyCustomerItem>[];

  String get currentReportId => args.reportId;

  @override
  void onInit() {
    super.onInit();
    if (args.reportDetails != null) {
      _loadItems();
    } else {
      refreshData();
    }
  }

  void _loadItems([SalesTeamReportDetailsModel? newDetails]) {
    final details = newDetails ?? args.reportDetails;
    if (details != null) {
      final all = <SalesTeamReportCustomerModel>[
        ...?details.pendingCustomers,
        ...?details.completedCustomers,
      ];

      _items.clear();
      for (final c in all) {
        final isVisited =
            details.completedCustomers?.any((e) => e.id == c.id) ?? false;
        _items.add(
          ColonyCustomerItem(
            id: c.id?.toString() ?? '',
            name: c.ownerName ?? c.companyName ?? 'Customer',
            category: c.companyName ?? 'Shop',
            role: 'Owner', // Default or from data
            email: c.email ?? '',
            phone: c.phone ?? '',
            status: isVisited
                ? ColonyCustomerStatus.visited
                : ColonyCustomerStatus.overdue,
            statusDateLabel: details.date ?? '',
            primaryActionLabel: isVisited ? 'Add Machinery' : 'Mark as Visited',
            secondaryActionLabel: 'Add Note',
          ),
        );
      }
    }
  }

  List<ColonyCustomerItem> get visibleCustomers {
    switch (filter) {
      case ColonyCustomerListFilter.all:
        return List<ColonyCustomerItem>.from(_items);
      case ColonyCustomerListFilter.visited:
        return _items
            .where(
              (ColonyCustomerItem e) =>
                  e.status == ColonyCustomerStatus.visited,
            )
            .toList();
      case ColonyCustomerListFilter.overdue:
        return _items
            .where(
              (ColonyCustomerItem e) =>
                  e.status == ColonyCustomerStatus.overdue,
            )
            .toList();
    }
  }

  void setFilter(ColonyCustomerListFilter value) {
    filter = value;
    update();
  }

  Future<void> markColonyVisited() async {
    final String reportId = currentReportId;
    if (reportId == '0' || reportId.isEmpty) return;
    isLoading = true;
    update();

    try {
      await apiService.put("/sales_team/report/$reportId", {
        'is_visited': true,
      }, authReq: true);

      showCustomSnackBar("Colony marked as visited", isError: false);
      await refreshData();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> markCustomerVisited(String customerId) async {
    final String reportId = currentReportId;
    if (reportId == '0' || reportId.isEmpty) return;

    isLoading = true;
    update();

    try {
      // Gather all currently visited customer IDs from the local state
      final Set<int> visitedIds = _items
          .where(
            (ColonyCustomerItem e) => e.status == ColonyCustomerStatus.visited,
          )
          .map((ColonyCustomerItem e) => int.tryParse(e.id) ?? 0)
          .where((int id) => id != 0)
          .toSet();

      // Add the newly visited customer ID
      final int newId = int.tryParse(customerId) ?? 0;
      if (newId != 0) visitedIds.add(newId);

      await apiService.put("/sales_team/report/$reportId", {
        'completed_customer_ids': visitedIds.toList(),
      }, authReq: true);

      showCustomSnackBar("Customer marked as visited", isError: false);
      await refreshData();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> addNote(String customerId, String noteText) async {
    final String reportId = currentReportId;
    if (reportId == '0' || reportId.isEmpty || noteText.trim().isEmpty) return;

    try {
      await apiService.put("/sales_team/report/$reportId", {
        'notes': [
          {
            'customer_id': int.tryParse(customerId) ?? 0,
            'note': noteText.trim(),
          },
        ],
      }, authReq: true);

      showCustomSnackBar("Note saved successfully", isError: false);
      update();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> refreshData() async {
    final String reportId = currentReportId;
    if (reportId == '0' || reportId.isEmpty) return;
    isLoading = true;
    update();

    try {
      final response = await apiService.get(
        "/sales_team/report/$reportId",
        authReq: true,
      );
      final raw = response.data;
      final data = raw is Map<String, dynamic> ? raw['data'] : null;
      if (data != null) {
        final details = SalesTeamReportDetailsModel.fromJson(data);
        _loadItems(details);
      }
    } catch (e) {
      // Quietly fail or show snackbar
    } finally {
      isLoading = false;
      update();
    }
  }
}

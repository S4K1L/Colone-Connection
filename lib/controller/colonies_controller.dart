import 'package:flutter/material.dart';
import 'package:flutter_extension/data/model/colony_list_item_model.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:get/get.dart';

enum ColonyVisitFilter { all, visited, notVisited }

class ColoniesController extends GetxController {
  static const int totalColonies = 56;

  ColonyVisitFilter filter = ColonyVisitFilter.all;
  DateTime selectedDate = DateTime(2026, 3, 5);

  final List<ColonyListItem> _items = <ColonyListItem>[
    const ColonyListItem(
      id: '1',
      name: 'Green Valley Colony',
      area: 'North Delhi',
      isVisited: true,
      statusDateLabel: '5 March, 2026',
      customers: 125,
      visitedCount: 40,
      overdueCount: 5,
      lastVisitLabel: '3 days ago',
    ),
    const ColonyListItem(
      id: '2',
      name: 'Green Valley Colony',
      area: 'North Delhi',
      isVisited: true,
      statusDateLabel: '5 March, 2026',
      customers: 45,
      visitedCount: 40,
      overdueCount: null,
      lastVisitLabel: '3 days ago',
    ),
    const ColonyListItem(
      id: '3',
      name: 'Green Valley Colony',
      area: 'North Delhi',
      isVisited: false,
      statusDateLabel: '5 March, 2026',
      customers: 45,
      visitedCount: null,
      overdueCount: null,
      lastVisitLabel: '3 days ago',
    ),
  ];

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
      update();
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
        colonyId: item.id,
        colonyName: item.name,
        totalCustomers: item.customers,
        colonyArea: item.area,
      ),
    );
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

import 'package:flutter_extension/model/colony_customer_model.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:get/get.dart';

enum ColonyCustomerListFilter { all, visited, overdue }

class ColonyCustomersController extends GetxController {
  ColonyCustomersController({required this.args});

  final ColonyCustomersArgs args;

  ColonyCustomerListFilter filter = ColonyCustomerListFilter.all;

  final List<ColonyCustomerItem> _items = <ColonyCustomerItem>[
    const ColonyCustomerItem(
      id: 'cu1',
      name: 'Rajesh Kumar',
      category: 'Truck Parts',
      role: 'Shop Keeper',
      email: 'rajesh.k@example.com',
      phone: '+91 98765 43210',
      status: ColonyCustomerStatus.visited,
      statusDateLabel: '5 March, 2026',
      primaryActionLabel: 'Add Machinery',
      secondaryActionLabel: 'Add Note',
    ),
    const ColonyCustomerItem(
      id: 'cu2',
      name: 'Priya Sharma',
      category: 'Industrial Supply',
      role: 'Owner',
      email: 'priya.s@example.com',
      phone: '+91 98765 11111',
      status: ColonyCustomerStatus.overdue,
      statusDateLabel: '5 March, 2026',
      primaryActionLabel: 'Mark as Visited',
      secondaryActionLabel: 'Add Note',
    ),
    const ColonyCustomerItem(
      id: 'cu3',
      name: 'Amit Verma',
      category: 'Auto Parts',
      role: 'Manager',
      email: 'amit.v@example.com',
      phone: '+91 98765 22222',
      status: ColonyCustomerStatus.visited,
      statusDateLabel: '5 March, 2026',
      primaryActionLabel: 'Add Machinery',
      secondaryActionLabel: 'Add Note',
    ),
  ];

  List<ColonyCustomerItem> get visibleCustomers {
    switch (filter) {
      case ColonyCustomerListFilter.all:
        return List<ColonyCustomerItem>.from(_items);
      case ColonyCustomerListFilter.visited:
        return _items
            .where((ColonyCustomerItem e) =>
                e.status == ColonyCustomerStatus.visited)
            .toList();
      case ColonyCustomerListFilter.overdue:
        return _items
            .where((ColonyCustomerItem e) =>
                e.status == ColonyCustomerStatus.overdue)
            .toList();
    }
  }

  void setFilter(ColonyCustomerListFilter value) {
    filter = value;
    update();
  }
}

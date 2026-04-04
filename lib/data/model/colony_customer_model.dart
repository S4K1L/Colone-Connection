/// Customer row on the colony detail (customers) screen.
enum ColonyCustomerStatus { visited, overdue }

class ColonyCustomerItem {
  const ColonyCustomerItem({
    required this.id,
    required this.name,
    required this.category,
    this.role = 'Shop Keeper',
    required this.email,
    required this.phone,
    required this.status,
    required this.statusDateLabel,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
  });

  final String id;
  final String name;
  final String category;
  final String role;
  final String email;
  final String phone;
  final ColonyCustomerStatus status;
  final String statusDateLabel;
  /// e.g. "Add Machinery" or "Mark as Visited"
  final String primaryActionLabel;
  final String secondaryActionLabel;
}

/// One row in the Colonies list (dashboard card).
class ColonyListItem {
  const ColonyListItem({
    required this.id,
    required this.name,
    required this.area,
    required this.isVisited,
    required this.statusDateLabel,
    required this.customers,
    this.visitedCount,
    this.overdueCount,
    required this.lastVisitLabel,
  });

  final String id;
  final String name;
  final String area;
  final bool isVisited;
  final String statusDateLabel;
  final int customers;
  final int? visitedCount;
  final int? overdueCount;
  final String lastVisitLabel;

  bool get showsOnlyCustomers => visitedCount == null && overdueCount == null;
  bool get showsTwoStats =>
      visitedCount != null && overdueCount == null;
}

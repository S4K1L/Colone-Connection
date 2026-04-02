/// Result row for colony search (map + search overlay).
class SearchColonyResult {
  const SearchColonyResult({
    required this.id,
    required this.name,
    required this.district,
    required this.customers,
    required this.lastVisitLabel,
  });

  final String id;
  final String name;
  final String district;
  final int customers;
  final String lastVisitLabel;
}

/// Result row for customer search.
class SearchCustomerResult {
  const SearchCustomerResult({
    required this.id,
    required this.colonyName,
    required this.role,
    required this.initials,
    required this.phone,
    required this.email,
  });

  final String id;
  final String colonyName;
  final String role;
  final String initials;
  final String phone;
  final String email;
}

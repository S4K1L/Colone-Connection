class SalesTeamReportDetailsModel {
  const SalesTeamReportDetailsModel({
    this.id,
    this.date,
    this.isVisited,
    this.colony,
    this.pendingCustomers,
    this.completedCustomers,
    this.pendingCount,
    this.completedCount,
    this.totalCustomers,
  });

  final int? id;
  final String? date;
  final bool? isVisited;
  final SalesTeamReportColonyModel? colony;
  final List<SalesTeamReportCustomerModel>? pendingCustomers;
  final List<SalesTeamReportCustomerModel>? completedCustomers;
  final int? pendingCount;
  final int? completedCount;
  final int? totalCustomers;

  factory SalesTeamReportDetailsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> pendingRaw =
        json['pending_customers'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> completedRaw =
        json['completed_customers'] as List<dynamic>? ?? <dynamic>[];

    return SalesTeamReportDetailsModel(
      id: json['id'] as int?,
      date: json['date']?.toString(),
      isVisited: json['is_visited'] as bool?,
      colony: json['colony'] is Map<String, dynamic>
          ? SalesTeamReportColonyModel.fromJson(
              json['colony'] as Map<String, dynamic>,
            )
          : null,
      pendingCustomers: pendingRaw
          .whereType<Map<String, dynamic>>()
          .map(SalesTeamReportCustomerModel.fromJson)
          .toList(),
      completedCustomers: completedRaw
          .whereType<Map<String, dynamic>>()
          .map(SalesTeamReportCustomerModel.fromJson)
          .toList(),
      pendingCount: json['pending_count'] as int?,
      completedCount: json['completed_count'] as int?,
      totalCustomers: json['total_customers'] as int?,
    );
  }
}

class SalesTeamReportColonyModel {
  const SalesTeamReportColonyModel({
    this.id,
    this.name,
    this.region,
    this.status,
    this.locationUrl,
    this.latitude,
    this.longitude,
  });

  final int? id;
  final String? name;
  final String? region;
  final String? status;
  final String? locationUrl;
  final double? latitude;
  final double? longitude;

  factory SalesTeamReportColonyModel.fromJson(Map<String, dynamic> json) {
    return SalesTeamReportColonyModel(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      region: json['region']?.toString(),
      status: json['status']?.toString(),
      locationUrl: json['location_url']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }
}

class SalesTeamReportCustomerModel {
  const SalesTeamReportCustomerModel({
    this.id,
    this.ownerName,
    this.companyName,
    this.email,
    this.phone,
    this.status,
    this.city,
    this.state,
    this.country,
  });

  final int? id;
  final String? ownerName;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? status;
  final String? city;
  final String? state;
  final String? country;

  factory SalesTeamReportCustomerModel.fromJson(Map<String, dynamic> json) {
    return SalesTeamReportCustomerModel(
      id: json['id'] as int?,
      ownerName: json['owner_name']?.toString(),
      companyName: json['company_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

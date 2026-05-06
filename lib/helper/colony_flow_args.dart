import 'package:flutter_extension/model/sales_team_report_details_model.dart';

/// [Get.arguments] for [ColonyCustomersScreen].
class ColonyCustomersArgs {
  const ColonyCustomersArgs({
    required this.colonyId,
    required this.reportId,
    required this.colonyName,
    required this.totalCustomers,
    this.colonyArea = 'North Delhi',
    this.reportDetails,
  });

  final String colonyId;
  final String reportId;
  final String colonyName;
  final int totalCustomers;
  final String colonyArea;
  final SalesTeamReportDetailsModel? reportDetails;
}

/// [Get.arguments] for [AddCustomerScreen].
class AddCustomerArgs {
  const AddCustomerArgs({
    required this.colonyId,
    required this.colonyName,
  });

  final String colonyId;
  final String colonyName;
}

/// [Get.arguments] for [CustomerDetailScreen].
class CustomerDetailArgs {
  const CustomerDetailArgs({
    required this.name,
    required this.category,
    required this.email,
    required this.phone,
    required this.statusLabel,
    required this.statusDateLabel,
    required this.customerId,
    required this.reportId,
    this.role = 'Shop Keeper',
    this.colonyName = '',
    this.colonyArea = '',
    this.reportDetails,
    this.shouldShowMachinery = false,
    this.shouldShowNotes = false,
  });

  final String name;
  final String category;
  final String email;
  final String phone;
  final String statusLabel;
  final String statusDateLabel;
  final String customerId;
  final String reportId;
  /// Shown under the name in the green header (e.g. Shop Keeper).
  final String role;
  /// Used for [ColonyNavigateScreen] when opening from Navigate.
  final String colonyName;
  final String colonyArea;
  final SalesTeamReportDetailsModel? reportDetails;
  final bool shouldShowMachinery;
  final bool shouldShowNotes;
}

/// [Get.arguments] for [ColonyNavigateScreen] (colony route / directions).
class ColonyNavigateArgs {
  const ColonyNavigateArgs({
    this.titleFull = 'Green Valley Colony',
    this.area = 'North Delhi',
    this.distanceKm = '1',
    this.etaMinutes = '6',
  });

  final String titleFull;
  final String area;
  final String distanceKm;
  final String etaMinutes;
}

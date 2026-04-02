import 'package:google_maps_flutter/google_maps_flutter.dart';

/// One ordered stop on a planned colony route.
class RouteStopModel {
  const RouteStopModel({
    required this.id,
    required this.colonyName,
    required this.region,
    required this.customers,
    required this.position,
    required this.shortMapLabel,
  });

  final String id;
  final String colonyName;
  final String region;
  final int customers;
  final LatLng position;

  /// Short label shown on map preview (e.g. Green, Sunrise).
  final String shortMapLabel;
}

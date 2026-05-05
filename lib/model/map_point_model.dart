import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPointModel {
  const MapPointModel({
    required this.id,
    required this.name,
    required this.region,
    required this.visits,
    required this.customers,
    required this.isVisited,
    required this.position,
  });

  final String id;
  final String name;
  final String region;
  final int visits;
  final int customers;
  final bool isVisited;
  final LatLng position;
}

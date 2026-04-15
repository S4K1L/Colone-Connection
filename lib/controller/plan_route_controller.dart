import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/data/model/route_stop_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RouteFlowStage { planning, nextStop, navigating }

class PlanRouteController extends GetxController {
  RouteFlowStage stage = RouteFlowStage.planning;

  final List<RouteStopModel> stops = <RouteStopModel>[];

  /// Next stop index in [stops] (0-based).
  int currentStopIndex = 0;

  int visitedColoniesCount = 0;

  GoogleMapController? mapController;
  double _currentZoom = 14;

  final Set<Marker> markers = <Marker>{};
  Set<Polyline> _routePolylines = <Polyline>{};
  bool _isFetchingRoadPolyline = false;
  final Map<int, BitmapDescriptor> _numberIcons = <int, BitmapDescriptor>{};
  static const List<Color> _routeLegColors = <Color>[
    Color(0xFF4285F4), // Blue
    Color(0xFFF4B400), // Yellow
    Color(0xFF34A853), // Green
    Color(0xFFEA4335), // Red
    Color(0xFF9C27B0), // Purple
  ];

  static const List<String> _shortLabels = <String>[
    'Green',
    'Sunrise',
    'Royal',
    'Silver',
  ];

  static const List<String> _regions = <String>[
    'North Delhi',
    'East Delhi',
    'West Delhi',
    'South Delhi',
  ];

  bool get hasMapsKey => (dotenv.env['GOOGLE_API_KEY'] ?? '').isNotEmpty;

  RouteStopModel? get currentTarget {
    if (currentStopIndex < 0 || currentStopIndex >= stops.length) {
      return null;
    }
    return stops[currentStopIndex];
  }

  int get activeColonyCount => stops.length;

  int get totalRouteCustomers =>
      stops.fold<int>(0, (int t, RouteStopModel s) => t + s.customers);

  /// Planning / next-stop summary stats (mock).
  String get planningDistanceLabel => '6 KM';
  String get planningDurationLabel => '3h 30m';

  /// Navigating leg (mock).
  String get navigatingDistanceLabel => '1 KM';
  String get navigatingEtaLabel => '6 m';

  @override
  void onInit() {
    super.onInit();
    _initializeOptimizedRoute();
  }

  Future<void> _initializeOptimizedRoute() async {
    _loadStopsFromHome();
    final LatLng startPoint = await _resolveStartPoint();
    _optimizeStopsByNearestNeighbor(startPoint);
    await _buildMarkers();
    await _refreshRoadPolyline();
    if (mapController != null) {
      await fitCameraToStops();
    }
  }

  Future<LatLng> _resolveStartPoint() async {
    try {
      final LocationPermission permission = await Geolocator.checkPermission();
      LocationPermission grantedPermission = permission;
      if (permission == LocationPermission.denied) {
        grantedPermission = await Geolocator.requestPermission();
      }

      final bool canUseLocation =
          grantedPermission == LocationPermission.always ||
          grantedPermission == LocationPermission.whileInUse;
      if (!canUseLocation) {
        return HomeController.center;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return HomeController.center;
    }
  }

  void _optimizeStopsByNearestNeighbor(LatLng startPoint) {
    if (stops.length < 2) {
      return;
    }

    final List<RouteStopModel> remaining = List<RouteStopModel>.from(stops);
    final List<RouteStopModel> optimized = <RouteStopModel>[];
    LatLng cursor = startPoint;

    while (remaining.isNotEmpty) {
      int nearestIndex = 0;
      double nearestDistance = double.infinity;

      for (int i = 0; i < remaining.length; i++) {
        final RouteStopModel candidate = remaining[i];
        final double distance = Geolocator.distanceBetween(
          cursor.latitude,
          cursor.longitude,
          candidate.position.latitude,
          candidate.position.longitude,
        );
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestIndex = i;
        }
      }

      final RouteStopModel nearest = remaining.removeAt(nearestIndex);
      optimized.add(nearest);
      cursor = nearest.position;
    }

    stops
      ..clear()
      ..addAll(optimized);
  }

  void _loadStopsFromHome() {
    stops.clear();
    if (Get.isRegistered<HomeController>()) {
      final HomeController home = Get.find<HomeController>();
      for (int i = 0; i < home.points.length; i++) {
        final p = home.points[i];
        stops.add(
          RouteStopModel(
            id: p.id,
            colonyName: p.name,
            region: _regions[i % _regions.length],
            customers: p.customers,
            position: p.position,
            shortMapLabel: _shortLabels[i % _shortLabels.length],
          ),
        );
      }
    }
    if (stops.isEmpty) {
      stops.addAll(_fallbackStops);
    }
  }

  static final List<RouteStopModel> _fallbackStops = <RouteStopModel>[
    const RouteStopModel(
      id: 'r1',
      colonyName: 'Mohakhali DOHS',
      region: 'Mohakhali',
      customers: 45,
      position: LatLng(23.7809, 90.4050),
      shortMapLabel: 'Green',
    ),
    const RouteStopModel(
      id: 'r2',
      colonyName: 'Wireless Gate Colony',
      region: 'Mohakhali',
      customers: 32,
      position: LatLng(23.7788, 90.4084),
      shortMapLabel: 'Sunrise',
    ),
  ];

  Future<void> _buildMarkers() async {
    markers.clear();
    for (int i = 0; i < stops.length; i++) {
      final int order = i + 1;
      if (!_numberIcons.containsKey(order)) {
        _numberIcons[order] = await _createNumberedMarker(order);
      }
      final BitmapDescriptor icon = _numberIcons[order]!;
      markers.add(
        Marker(
          markerId: MarkerId(stops[i].id),
          position: stops[i].position,
          icon: icon,
          // Circular markers should be centered on the route point.
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: '$order. ${stops[i].shortMapLabel}',
            snippet: stops[i].colonyName,
          ),
        ),
      );
    }
    update();
  }

  Future<BitmapDescriptor> _createNumberedMarker(int number) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const double size = 96;
    const Offset c = Offset(size / 2, size / 2);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawCircle(c.translate(0, 7), 24, shadowPaint);

    canvas.drawCircle(c, 21.5, Paint()..color = AppColors.white);
    canvas.drawCircle(c, 16.5, Paint()..color = AppColors.green500);

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));

    final ui.Image image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Set<Polyline> buildPolylines() {
    if (_routePolylines.isNotEmpty) {
      return _routePolylines;
    }
    return _buildFallbackPolyline();
  }

  Set<Polyline> _buildFallbackPolyline() {
    if (stops.length < 2) {
      return <Polyline>{};
    }
    final Set<Polyline> legPolylines = <Polyline>{};
    for (int i = 0; i < stops.length - 1; i++) {
      legPolylines.add(
        Polyline(
          polylineId: PolylineId('planned_route_fallback_leg_$i'),
          color: _routeLegColors[i % _routeLegColors.length],
          width: 5,
          geodesic: true,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          points: <LatLng>[stops[i].position, stops[i + 1].position],
        ),
      );
    }
    return legPolylines;
  }

  Future<void> _refreshRoadPolyline() async {
    if (_isFetchingRoadPolyline) {
      return;
    }
    if (!hasMapsKey || stops.length < 2) {
      _routePolylines = _buildFallbackPolyline();
      update();
      return;
    }

    _isFetchingRoadPolyline = true;
    try {
      final String key = dotenv.env['GOOGLE_API_KEY'] ?? '';
      final RouteStopModel origin = stops.first;
      final RouteStopModel destination = stops.last;
      final List<RouteStopModel> viaStops = stops.length > 2
          ? stops.sublist(1, stops.length - 1)
          : <RouteStopModel>[];

      final Map<String, String> params = <String, String>{
        'origin': '${origin.position.latitude},${origin.position.longitude}',
        'destination':
            '${destination.position.latitude},${destination.position.longitude}',
        'mode': 'driving',
        'key': key,
      };
      if (viaStops.isNotEmpty) {
        params['waypoints'] = viaStops
            .map((RouteStopModel s) => '${s.position.latitude},${s.position.longitude}')
            .join('|');
      }

      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        params,
      );

      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      final String bodyText = await utf8.decoder.bind(response).join();
      client.close();

      if (response.statusCode != 200 || bodyText.isEmpty) {
        _routePolylines = _buildFallbackPolyline();
        update();
        return;
      }

      final dynamic body = jsonDecode(bodyText);
      final String apiStatus = (body['status'] ?? '') as String;
      if (apiStatus != 'OK') {
        _routePolylines = _buildFallbackPolyline();
        update();
        return;
      }

      final List<dynamic> routes = (body['routes'] as List<dynamic>? ?? <dynamic>[]);
      if (routes.isEmpty) {
        _routePolylines = _buildFallbackPolyline();
        update();
        return;
      }

      final Map<String, dynamic> route0 = routes.first as Map<String, dynamic>;
      final List<dynamic> legs = route0['legs'] as List<dynamic>? ?? <dynamic>[];
      final Set<Polyline> legPolylines = <Polyline>{};
      for (int legIndex = 0; legIndex < legs.length; legIndex++) {
        final Map<String, dynamic> leg =
            legs[legIndex] as Map<String, dynamic>? ?? <String, dynamic>{};
        final List<dynamic> steps = leg['steps'] as List<dynamic>? ?? <dynamic>[];

        final List<LatLng> legPoints = <LatLng>[];
        for (int stepIndex = 0; stepIndex < steps.length; stepIndex++) {
          final Map<String, dynamic> step =
              steps[stepIndex] as Map<String, dynamic>? ?? <String, dynamic>{};
          final Map<String, dynamic> stepPolyline =
              step['polyline'] as Map<String, dynamic>? ?? <String, dynamic>{};
          final String encodedStep = (stepPolyline['points'] ?? '') as String;
          final List<LatLng> decodedStep = _decodePolyline(encodedStep);
          if (decodedStep.isEmpty) {
            continue;
          }
          if (legPoints.isEmpty) {
            legPoints.addAll(decodedStep);
          } else {
            legPoints.addAll(decodedStep.skip(1));
          }
        }

        if (legPoints.length >= 2) {
          legPolylines.add(
            Polyline(
              polylineId: PolylineId('planned_route_leg_$legIndex'),
              color: _routeLegColors[legIndex % _routeLegColors.length],
              width: 6,
              geodesic: true,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              points: legPoints,
            ),
          );
        }
      }

      if (legPolylines.isEmpty) {
        _routePolylines = _buildFallbackPolyline();
      } else {
        _routePolylines = legPolylines;
      }
      update();
    } catch (_) {
      _routePolylines = _buildFallbackPolyline();
      update();
    } finally {
      _isFetchingRoadPolyline = false;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) {
      return <LatLng>[];
    }
    final List<LatLng> polyline = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < encoded.length);
      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return polyline;
  }

  LatLngBounds? boundsForStops() {
    if (stops.isEmpty) {
      return null;
    }
    double minLat = stops.first.position.latitude;
    double maxLat = minLat;
    double minLng = stops.first.position.longitude;
    double maxLng = minLng;
    for (final RouteStopModel s in stops) {
      minLat = minLat < s.position.latitude ? minLat : s.position.latitude;
      maxLat = maxLat > s.position.latitude ? maxLat : s.position.latitude;
      minLng = minLng < s.position.longitude ? minLng : s.position.longitude;
      maxLng = maxLng > s.position.longitude ? maxLng : s.position.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> fitCameraToStops({double padding = 56}) async {
    final LatLngBounds? b = boundsForStops();
    if (b == null || mapController == null) {
      return;
    }
    await mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(b, padding),
    );
  }

  void onMapCreated(GoogleMapController c) {
    mapController = c;
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      fitCameraToStops();
    });
    _refreshRoadPolyline();
  }

  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  Future<void> zoomIn() async {
    if (mapController == null) return;
    _currentZoom = (_currentZoom + 1).clamp(3.0, 20.0);
    await mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  Future<void> zoomOut() async {
    if (mapController == null) return;
    _currentZoom = (_currentZoom - 1).clamp(3.0, 20.0);
    await mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final RouteStopModel item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);
    currentStopIndex = 0;
    update();
    _buildMarkers().then((_) => update());
    _refreshRoadPolyline();
  }

  void removeStop(String id) {
    stops.removeWhere((RouteStopModel s) => s.id == id);
    if (stops.isEmpty) {
      currentStopIndex = 0;
    } else if (currentStopIndex >= stops.length) {
      currentStopIndex = stops.length - 1;
    }
    _optimizeStopsByNearestNeighbor(HomeController.center);
    currentStopIndex = 0;
    update();
    _buildMarkers().then((_) => update());
    _refreshRoadPolyline();
  }

  void startNavigation() {
    visitedColoniesCount = 0;
    currentStopIndex = 0;
    stage = RouteFlowStage.nextStop;
    _refreshRoadPolyline();
    update();
  }

  void goToNavigating() {
    stage = RouteFlowStage.navigating;
    _refreshRoadPolyline();
    update();
  }

  void markVisited() {
    if (currentStopIndex >= stops.length || stops.isEmpty) {
      return;
    }
    visitedColoniesCount++;
    currentStopIndex++;
    if (currentStopIndex >= stops.length) {
      Get.snackbar('Route', 'All colony on this route are visited.');
      stage = RouteFlowStage.planning;
      visitedColoniesCount = 0;
      currentStopIndex = 0;
    }
    update();
  }

  void onHeaderBack() {
    if (stage == RouteFlowStage.planning) {
      Get.back();
      return;
    }
    if (stage == RouteFlowStage.nextStop) {
      stage = RouteFlowStage.planning;
      update();
      return;
    }
    stage = RouteFlowStage.nextStop;
    update();
  }

  void onAddNote() {
    Get.snackbar('Note', 'Notes can be wired to your backend later.');
  }

  @override
  void onClose() {
    mapController = null;
    super.onClose();
  }
}

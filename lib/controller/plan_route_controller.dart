import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/data/model/route_stop_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
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

  final Set<Marker> markers = <Marker>{};
  final Map<int, BitmapDescriptor> _numberIcons = <int, BitmapDescriptor>{};

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
    _loadStopsFromHome();
    _buildMarkers();
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
      colonyName: 'Green Valley Colony',
      region: 'North Delhi',
      customers: 45,
      position: LatLng(23.7814, 90.2700),
      shortMapLabel: 'Green',
    ),
    const RouteStopModel(
      id: 'r2',
      colonyName: 'Sunrise Estate',
      region: 'North Delhi',
      customers: 32,
      position: LatLng(23.7789, 90.2860),
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
    if (stops.length < 2) {
      return <Polyline>{};
    }
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('planned_route'),
        color: const Color(0xFF4285F4),
        width: 5,
        points: stops.map((RouteStopModel s) => s.position).toList(),
      ),
    };
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
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final RouteStopModel item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);
    update();
    _buildMarkers().then((_) => update());
  }

  void removeStop(String id) {
    stops.removeWhere((RouteStopModel s) => s.id == id);
    if (stops.isEmpty) {
      currentStopIndex = 0;
    } else if (currentStopIndex >= stops.length) {
      currentStopIndex = stops.length - 1;
    }
    update();
    _buildMarkers().then((_) => update());
  }

  void startNavigation() {
    visitedColoniesCount = 0;
    currentStopIndex = 0;
    stage = RouteFlowStage.nextStop;
    update();
  }

  void goToNavigating() {
    stage = RouteFlowStage.navigating;
    update();
  }

  void markVisited() {
    if (currentStopIndex >= stops.length || stops.isEmpty) {
      return;
    }
    visitedColoniesCount++;
    currentStopIndex++;
    if (currentStopIndex >= stops.length) {
      Get.snackbar('Route', 'All colonies on this route are visited.');
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

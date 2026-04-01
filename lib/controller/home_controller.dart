import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_extension/data/model/map_point_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static const LatLng center = LatLng(23.7808, 90.2792);
  final TextEditingController searchController = TextEditingController();

  final List<MapPointModel> points = <MapPointModel>[
    const MapPointModel(
      id: 'm1',
      name: 'Blue Ridge Estate',
      visits: 15,
      customers: 58,
      isVisited: true,
      position: LatLng(23.7814, 90.2700),
    ),
    const MapPointModel(
      id: 'm2',
      name: 'Mirpur Colony',
      visits: 8,
      customers: 40,
      isVisited: false,
      position: LatLng(23.7789, 90.2860),
    ),
    const MapPointModel(
      id: 'm3',
      name: 'Savar North',
      visits: 11,
      customers: 36,
      isVisited: true,
      position: LatLng(23.7753, 90.2790),
    ),
    const MapPointModel(
      id: 'm4',
      name: 'Sheorapara Point',
      visits: 5,
      customers: 20,
      isVisited: false,
      position: LatLng(23.7855, 90.2850),
    ),
  ];

  final Set<Marker> markers = <Marker>{};
  BitmapDescriptor? _greenMarkerIcon;
  BitmapDescriptor? _redMarkerIcon;
  MapPointModel? selectedPoint;
  bool isSearchOpen = false;

  bool get hasMapsKey => (dotenv.env['GOOGLE_API_KEY'] ?? '').isNotEmpty;

  int get totalVisited => points.where((MapPointModel e) => e.isVisited).length;
  int get totalCustomers =>
      points.fold<int>(0, (int total, MapPointModel e) => total + e.customers);
  int get totalVisits => points.fold<int>(0, (int total, MapPointModel e) => total + e.visits);

  @override
  void onInit() {
    super.onInit();
    buildCustomMarkers();
  }

  Future<void> buildCustomMarkers() async {
    _greenMarkerIcon = await _createCircleMarker(AppColors.green500);
    _redMarkerIcon = await _createCircleMarker(AppColors.errorColor);

    final Set<Marker> generated = <Marker>{};
    for (final MapPointModel point in points) {
      generated.add(
        Marker(
          markerId: MarkerId(point.id),
          position: point.position,
          icon: point.isVisited ? _greenMarkerIcon! : _redMarkerIcon!,
          onTap: () => onMarkerTap(point),
        ),
      );
    }

    markers
      ..clear()
      ..addAll(generated);
    update();
  }

  void onMarkerTap(MapPointModel point) {
    selectedPoint = point;
    update();
  }

  void clearSelectedPoint() {
    if (selectedPoint == null) return;
    selectedPoint = null;
    update();
  }

  void openSearch() {
    isSearchOpen = true;
    update();
  }

  void closeSearch() {
    if (!isSearchOpen) return;
    isSearchOpen = false;
    searchController.clear();
    update();
  }

  Future<BitmapDescriptor> _createCircleMarker(Color color) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const double size = 96;
    const Offset centerOffset = Offset(size / 2, size / 2);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.16)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.drawCircle(centerOffset.translate(0, 7), 24, shadowPaint);

    final Paint whiteRing = Paint()..color = AppColors.white;
    canvas.drawCircle(centerOffset, 21.5, whiteRing);

    final Paint fillPaint = Paint()..color = color;
    canvas.drawCircle(centerOffset, 16.5, fillPaint);

    final ui.Image image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

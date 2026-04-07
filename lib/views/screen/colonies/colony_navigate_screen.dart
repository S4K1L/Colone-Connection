import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/colony_navigate_controller.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ColonyNavigateScreen extends StatefulWidget {
  const ColonyNavigateScreen({super.key});

  static const List<LatLng> _routePoints = <LatLng>[
    LatLng(23.7808, 90.2792),
    LatLng(23.7840, 90.2838),
    LatLng(23.7875, 90.2788),
  ];

  @override
  State<ColonyNavigateScreen> createState() => _ColonyNavigateScreenState();
}

class _ColonyNavigateScreenState extends State<ColonyNavigateScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final ColonyNavigateArgs args = Get.arguments is ColonyNavigateArgs
        ? Get.arguments as ColonyNavigateArgs
        : const ColonyNavigateArgs();
    Get.put(ColonyNavigateController(args: args));
  }

  @override
  void dispose() {
    if (Get.isRegistered<ColonyNavigateController>()) {
      Get.delete<ColonyNavigateController>();
    }
    super.dispose();
  }

  void _fitRoute() {
    if (_mapController == null) return;
    const List<LatLng> pts = ColonyNavigateScreen._routePoints;
    double minLat = pts.first.latitude;
    double maxLat = pts.first.latitude;
    double minLng = pts.first.longitude;
    double maxLng = pts.first.longitude;
    for (final LatLng p in pts) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.002, minLng - 0.002),
          northeast: LatLng(maxLat + 0.002, maxLng + 0.002),
        ),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.green25,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<ColonyNavigateController>(
          builder: (ColonyNavigateController c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _NavigateHeader(args: c.args),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24.r),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: Offset(0, -2.h),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      AppText.smd(
                                        '${c.args.distanceKm} KM',
                                        fontSize: 20,
                                        color: AppColors.grey500,
                                        useResponsiveSize: true,
                                      ),
                                      SizedBox(height: 4.h),
                                      const AppText.rg(
                                        'Distance',
                                        fontSize: 12,
                                        color: AppColors.grey300,
                                        useResponsiveSize: true,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40.h,
                                  color: AppColors.grey50,
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      AppText.smd(
                                        '${c.args.etaMinutes} m',
                                        fontSize: 20,
                                        color: AppColors.grey500,
                                        useResponsiveSize: true,
                                      ),
                                      SizedBox(height: 4.h),
                                      const AppText.rg(
                                        'ETA',
                                        fontSize: 12,
                                        color: AppColors.grey300,
                                        useResponsiveSize: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: c.tabIndex == 2
                            ? _MapPanel(
                                hasMapsKey: home.hasMapsKey,
                                routePoints: ColonyNavigateScreen._routePoints,
                                onMapCreated: (GoogleMapController ctrl) {
                                  _mapController = ctrl;
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _fitRoute(),
                                  );
                                },
                              )
                            : Container(
                                color: const Color(0xFFE8EAED),
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(24.w),
                                child: const AppText.rg(
                                  'Select the Machinery tab to view the navigation map.',
                                  fontSize: 14,
                                  color: AppColors.grey400,
                                  textAlign: TextAlign.center,
                                  useResponsiveSize: true,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                _ArrivedBar(onArrived: c.onArrived),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavigateHeader extends StatelessWidget {
  const _NavigateHeader({required this.args});

  final ColonyNavigateArgs args;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 16.w, 16.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF2EAD4B),
            Color(0xFF4BC76A),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            color: AppColors.white.withValues(alpha: 0.4),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => Get.back(),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText.smd(
                  args.titleFull,
                  fontSize: 20,
                  color: AppColors.white,
                  useResponsiveSize: true,
                ),
              ],
            ),
          ),
          AppText.rg(
            args.area,
            fontSize: 12,
            color: AppColors.white.withValues(alpha: 0.9),
            useResponsiveSize: true,
          ),
        ],
      ),
    );
  }
}
class _MapPanel extends StatelessWidget {
  const _MapPanel({
    required this.hasMapsKey,
    required this.routePoints,
    required this.onMapCreated,
  });

  final bool hasMapsKey;
  final List<LatLng> routePoints;
  final void Function(GoogleMapController) onMapCreated;

  @override
  Widget build(BuildContext context) {
    if (!hasMapsKey) {
      return Container(
        color: AppColors.grey50,
        alignment: Alignment.center,
        child: const AppText.rg(
          'Add GOOGLE_API_KEY to use the map.',
          fontSize: 13,
          color: AppColors.grey300,
          useResponsiveSize: true,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: routePoints.first,
            zoom: 14,
          ),
          polylines: <Polyline>{
            Polyline(
              polylineId: const PolylineId('nav_route'),
              color: const Color(0xFF1E88E5),
              width: 5,
              points: routePoints,
            ),
          },
          markers: <Marker>{
            Marker(
              markerId: const MarkerId('nav_start'),
              position: routePoints.first,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
            Marker(
              markerId: const MarkerId('nav_end'),
              position: routePoints.last,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: onMapCreated,
        ),
        Positioned(
          left: 12.w,
          top: 12.h,
          child: const _MapCalloutChip(
            icon: Icons.directions_car_outlined,
            line1: '6 min',
            line2: '2.9 km',
          ),
        ),
        Positioned(
          right: 12.w,
          top: 72.h,
          child: const _MapCalloutChip(
            icon: Icons.directions_bus_outlined,
            line1: '11 min',
            line2: '',
          ),
        ),
      ],
    );
  }
}

class _MapCalloutChip extends StatelessWidget {
  const _MapCalloutChip({
    required this.icon,
    required this.line1,
    required this.line2,
  });

  final IconData icon;
  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10.r),
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18.sp, color: AppColors.grey400),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppText.smd(
                  line1,
                  fontSize: 12,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
                if (line2.isNotEmpty)
                  AppText.rg(
                    line2,
                    fontSize: 10,
                    color: AppColors.grey300,
                    useResponsiveSize: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrivedBar extends StatelessWidget {
  const _ArrivedBar({required this.onArrived});

  final VoidCallback onArrived;

  static const Color _mint = Color(0xFFEEF8EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: _mint,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: const Border(
          top: BorderSide(color: AppColors.green600, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            child: InkWell(
              onTap: onArrived,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16.h,
                  horizontal: 36.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: double.infinity,              
                      height: 30.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E6FE6),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person_pin_circle_rounded,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    const AppText.smd(
                      'Arrived',
                      fontSize: 14,
                      color: AppColors.grey500,
                      useResponsiveSize: true,
                      
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

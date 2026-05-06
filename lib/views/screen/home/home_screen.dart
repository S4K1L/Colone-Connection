// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/model/map_point_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/map_search_results_overlay.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/helper/route_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Offset? _popupOffset;
  String? _popupForId;
  double _currentZoom = 13.8;
  bool _hasFittedMarkers = false;
  double _mapHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermissionIfAndroid();
    });
  }

  Future<void> _requestLocationPermissionIfAndroid() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) return;
    await Permission.location.request();
  }

  Future<void> _updatePopupPosition(MapPointModel point) async {
    if (_mapController == null || !mounted) return;
    final ScreenCoordinate screen = await _mapController!.getScreenCoordinate(
      point.position,
    );
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final double dx = screen.x / dpr;
    final double dy = screen.y / dpr;

    if (!mounted) return;
    setState(() {
      _popupOffset = Offset(dx, dy);
      _popupForId = point.id;
    });
  }

  void _syncPopup(HomeController home) {
    if (home.selectedPoint == null) {
      if (_popupOffset != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _popupOffset = null);
        });
      }
      _popupForId = null;
      return;
    }

    if (_popupForId != home.selectedPoint!.id || _popupOffset == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePopupPosition(home.selectedPoint!);
      });
    }

    // Auto-fit markers once when they are loaded
    if (home.points.isNotEmpty &&
        _mapController != null &&
        !_hasFittedMarkers) {
      _hasFittedMarkers = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMarkers(home.points);
      });
    }
  }

  Future<void> _zoomIn() async {
    if (_mapController == null) return;
    _currentZoom = (_currentZoom + 1).clamp(3.0, 20.0);
    await _mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  Future<void> _zoomOut() async {
    if (_mapController == null) return;
    _currentZoom = (_currentZoom - 1).clamp(3.0, 20.0);
    await _mapController!.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  void _fitMarkers(List<MapPointModel> points) {
    if (_mapController == null || points.isEmpty) return;

    double? minLat, maxLat, minLng, maxLng;

    for (final MapPointModel p in points) {
      if (minLat == null || p.position.latitude < minLat) {
        minLat = p.position.latitude;
      }
      if (maxLat == null || p.position.latitude > maxLat) {
        maxLat = p.position.latitude;
      }
      if (minLng == null || p.position.longitude < minLng) {
        minLng = p.position.longitude;
      }
      if (maxLng == null || p.position.longitude > maxLng) {
        maxLng = p.position.longitude;
      }
    }

    if (minLat != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng!),
            northeast: LatLng(maxLat!, maxLng!),
          ),
          50.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final ProfileController profile = Get.find<ProfileController>();
    return GetBuilder<HomeController>(
      builder: (home) {
        _syncPopup(home);
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(
            child: home.showSearchResultsLayer
                ? MapSearchResultsOverlay(home: home)
                : Column(
                    children: <Widget>[
                      MapAppBar(home: home, profile: profile),
                      Expanded(child: _mapTab(context, controller)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _mapTab(BuildContext context, HomeController home) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _mapHeight = constraints.maxHeight;
        return Stack(
          children: <Widget>[
            if (home.hasMapsKey)
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: HomeController.center,
                  zoom: 13.8,
                ),
                markers: Set<Marker>.of(home.markers),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController c) {
                  _mapController = c;
                  if (home.points.isNotEmpty) {
                    _fitMarkers(home.points);
                  }
                },
                onTap: (_) {
                  home.clearSelectedPoint();
                  home.closeSearch();
                  if (mounted) setState(() => _popupOffset = null);
                },
                onCameraMove: (CameraPosition position) {
                  _currentZoom = position.zoom;
                  if (home.selectedPoint != null) {
                    _updatePopupPosition(home.selectedPoint!);
                  }
                },
                onCameraIdle: () {
                  if (home.selectedPoint != null) {
                    _updatePopupPosition(home.selectedPoint!);
                  }
                },
              )
        else
          Container(
            color: AppColors.grey50,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppText.md(
                  home.errorMessage?.isNotEmpty == true
                      ? home.errorMessage!
                      : 'Something went wrong',
                  fontSize: 12,
                  useResponsiveSize: true,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: home.getSalesTeamReport,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        Positioned(
          left: 14.w,
          top: 18.h,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.grey300.withValues(alpha: 0.22),
                  blurRadius: 14.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const AppText.smd(
                  'Status',
                  fontSize: 12,
                  useResponsiveSize: true,
                  color: AppColors.grey500,
                ),
                SizedBox(height: 8.h),
                _statusDot(AppColors.green500, 'Visited', fontSize: 12),
                SizedBox(height: 6.h),
                _statusDot(AppColors.errorColor, 'Not Visited', fontSize: 12),
              ],
            ),
          ),
        ),
        Positioned(
          right: 14.w,
          top: 148.h,
          child: Column(
            children: <Widget>[
              _floatingIcon(Icons.zoom_in, onTap: _zoomIn),
              SizedBox(height: 10.h),
              _floatingIcon(Icons.zoom_out, onTap: _zoomOut),
            ],
          ),
        ),
        Positioned(
          right: 16.w,
          bottom: 70.h,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed(AppRoutes.planRouteScreen),
              borderRadius: BorderRadius.circular(16.r),
              child: Ink(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.place_outlined,
                      color: AppColors.white,
                      size: 24.w,
                    ),
                    SizedBox(width: 8.w),
                    const AppText.smd(
                      'Plan Route',
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
            if (home.selectedPoint != null && _popupOffset != null)
              Positioned(
                left: (_popupOffset!.dx - (188.w / 2)).clamp(
                  8.w,
                  MediaQuery.of(context).size.width - 188.w - 8.w,
                ),
                bottom: (_mapHeight - _popupOffset!.dy) + 12.h,
                child: _markerPopupCard(home, home.selectedPoint!),
              ),
            if (home.isLoading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _markerPopupCard(HomeController home, MapPointModel point) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 188.w,
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.grey300.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppText.smd(
                point.name,
                fontSize: 14,
                useResponsiveSize: true,
                color: AppColors.grey500,
              ),
              SizedBox(height: 4.h),
              Row(
                children: <Widget>[
                  const AppText.rg(
                    'Visits: ',
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                  AppText.md(
                    '${point.visits}',
                    fontSize: 12,
                    useResponsiveSize: true,
                    color: Colors.blue,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: <Widget>[
                  const AppText.rg(
                    'Customers: ',
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                  AppText.md(
                    '${point.customers}',
                    fontSize: 12,
                    useResponsiveSize: true,
                    color: AppColors.green600,
                  ),
                ],
              ),
              SizedBox(height: 9.h),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    await home.fetchColonyReportDetails(point.id);
                    Get.back(); // close loading dialog

                    final details = home.colonyReportDetails;
                    if (details == null) {
                      Get.snackbar(
                        'Details',
                        home.colonyReportDetailsErrorMessage ??
                            'Failed to load details.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    Get.toNamed(
                      AppRoutes.colonyCustomers,
                      arguments: ColonyCustomersArgs(
                        colonyId: (details.colony?.id ?? point.id).toString(),
                        reportId: (details.id ?? 0).toString(),
                        colonyName: details.colony?.name ?? point.name,
                        totalCustomers: point.customers,
                        colonyArea: details.colony?.region ?? '',
                        reportDetails: details,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
                      ),
                    ),
                    child: const AppText.md(
                      'View Details',
                      fontSize: 12,
                      useResponsiveSize: true,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 22.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r)),
          ),
        ),
      ],
    );
  }

  Widget _statusDot(Color color, String label, {required double fontSize}) {
    return Row(
      children: <Widget>[
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        AppText.rg(
          label,
          fontSize: fontSize,
          useResponsiveSize: true,
          color: AppColors.grey400,
        ),
      ],
    );
  }

  Widget _floatingIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45.w,
        height: 45.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.grey300.withValues(alpha: 0.25),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Icon(icon, size: 28.w, color: AppColors.grey500),
      ),
    );
  }
}

class MapAppBar extends StatelessWidget {
  final HomeController home;
  final ProfileController profile;
  const MapAppBar({super.key, required this.home, required this.profile});

  @override
  Widget build(BuildContext context) {
    final double cornerR = 16.r;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(cornerR),
            bottomRight: Radius.circular(cornerR),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 100.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppText.smd(
                        'Hlw, ${profile.profile.fullName}',
                        fontSize: 24,
                        color: AppColors.white,
                        useResponsiveSize: true,
                      ),
                      SizedBox(height: 4.h),
                      AppText.rg(
                        home.todayLabel,
                        fontSize: 13,
                        color: AppColors.white80,
                        useResponsiveSize: true,
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  width: home.isSearchOpen ? 220.w : 38.w,
                  height: home.isSearchOpen ? 40.h : 38.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: home.isSearchOpen ? 12.w : 0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(
                      home.isSearchOpen ? 16.r : 11.r,
                    ),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.55),
                      width: 1,
                    ),
                  ),
                  child: home.isSearchOpen
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: home.searchController,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12.sp,
                                ),
                                cursorColor: AppColors.white,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Search colony or customers...',
                                  hintStyle: TextStyle(
                                    color: AppColors.white80,
                                    fontSize: 11.sp,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: home.closeSearch,
                              child: Icon(
                                Icons.close,
                                color: AppColors.white80,
                                size: 18.w,
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: home.openSearch,
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Icon(
                              Icons.search,
                              color: AppColors.white,
                              size: 19.w,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cornerR),
                topRight: Radius.circular(cornerR),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    _TopStat(
                      value: '${home.todayColonies}',
                      label: "Today's Colony",
                    ),
                    _StatColumnDivider(),
                    _TopStat(
                      value: '${home.totalCustomers}',
                      label: 'Total Customer',
                    ),
                    _StatColumnDivider(),
                    _TopStat(
                      value: '${home.totalVisits}',
                      label: 'Total Visited',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumnDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        width: 1,
        color: AppColors.grey100.withValues(alpha: 0.55),
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  const _TopStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AppText.smd(
            value,
            fontSize: 24,
            color: AppColors.grey500,
            textAlign: TextAlign.center,
            useResponsiveSize: true,
          ),
          SizedBox(height: 4.h),
          AppText.rg(
            label,
            fontSize: 12,
            color: AppColors.grey300,
            textAlign: TextAlign.center,
            useResponsiveSize: true,
          ),
        ],
      ),
    );
  }
}

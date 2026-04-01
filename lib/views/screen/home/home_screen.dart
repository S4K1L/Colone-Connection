import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/data/model/map_point_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

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

  Future<void> _updatePopupPosition(MapPointModel point) async {
    if (_mapController == null || !mounted) return;
    final ScreenCoordinate screen = await _mapController!.getScreenCoordinate(point.position);
    final double dpr = MediaQuery.of(context).devicePixelRatio;
    final double dx = screen.x / dpr;
    final double dy = screen.y / dpr;

    final double cardWidth = 188.w;
    final double popupHeight = 125.h;
    final double markerGap = 10.h;

    final double left = (dx - (cardWidth / 2)).clamp(8.w, MediaQuery.of(context).size.width - cardWidth - 8.w);
    final double top = dy - popupHeight - markerGap;

    if (!mounted) return;
    setState(() {
      _popupOffset = Offset(left, top);
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

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return GetBuilder<HomeController>(
      builder: (home) {
        _syncPopup(home);
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(child: _mapTab(context, controller)),
        );
      },
    );
  }

  Widget _mapTab(BuildContext context, HomeController home) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(14.r),
              bottomRight: Radius.circular(14.r),
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        AppText.smd('Hlw, Rahim', fontSize: 32 / 2, color: AppColors.white),
                        SizedBox(height: 2),
                        AppText.rg('March 5, 2026', fontSize: 13 / 2, color: AppColors.white80),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    width: home.isSearchOpen ? 220.w : 32.w,
                    height: home.isSearchOpen ? 36.h : 32.w,
                    padding: EdgeInsets.symmetric(horizontal: home.isSearchOpen ? 10.w : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.white70, width: 0.9),
                    ),
                    child: home.isSearchOpen
                        ? Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: home.searchController,
                                  style: TextStyle(color: AppColors.white, fontSize: 12.sp),
                                  cursorColor: AppColors.white,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Search colonies or customers...',
                                    hintStyle: TextStyle(
                                      color: AppColors.white80,
                                      fontSize: 9.5.sp,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: home.closeSearch,
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.white80,
                                  size: 16.w,
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: home.openSearch,
                            child: Center(
                              child: Icon(Icons.search, color: AppColors.white, size: 17.w),
                            ),
                          ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: <Widget>[
                    _TopStat(value: '${home.totalVisited}', label: "Today's Colonies"),
                    _TopStat(value: '${home.totalCustomers}', label: 'Total Customer'),
                    _TopStat(value: '${home.totalVisits}', label: 'Total Visited'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              if (home.hasMapsKey)
                GoogleMap(
                  initialCameraPosition: const CameraPosition(target: HomeController.center, zoom: 13.8),
                  markers: home.markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController c) => _mapController = c,
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
                )
              else
                Container(
                  color: AppColors.grey50,
                  alignment: Alignment.center,
                  child: const AppText.md(
                    'Something went wrong',
                    fontSize: 12,
                    useResponsiveSize: true,
                    color: AppColors.grey400,
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
                        color: AppColors.grey300.withOpacity(0.22),
                        blurRadius: 14.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const AppText.smd('Status', fontSize: 12, useResponsiveSize: true, color: AppColors.grey500),
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
                child: Container(
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
                      Icon(Icons.place_outlined, color: AppColors.white, size: 24.w),
                      SizedBox(width: 8.w),
                      const AppText.smd('Plan Route', fontSize: 16, color: AppColors.white),
                    ],
                  ),
                ),
              ),
              if (home.selectedPoint != null && _popupOffset != null)
                Positioned(
                  left: _popupOffset!.dx,
                  top: _popupOffset!.dy,
                  child: _markerPopupCard(home.selectedPoint!),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _markerPopupCard(MapPointModel point) {
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
                color: AppColors.grey300.withOpacity(0.24),
                blurRadius: 18,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppText.smd(point.name, fontSize: 14, useResponsiveSize: true, color: AppColors.grey500),
              SizedBox(height: 4.h),
              Row(
                children: <Widget>[
                  const AppText.rg('Visits: ', fontSize: 12, color: AppColors.grey500),
                  AppText.md('${point.visits}', fontSize: 12, useResponsiveSize: true, color: Colors.blue),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: <Widget>[
                  const AppText.rg('Customers: ', fontSize: 12, color: AppColors.grey500),
                  AppText.md('${point.customers}', fontSize: 12, useResponsiveSize: true, color: AppColors.green600),
                ],
              ),
              SizedBox(height: 9.h),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
                  ),
                ),
                child: const AppText.md('View Details', fontSize: 12, useResponsiveSize: true, color: AppColors.white),
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
        AppText.rg(label, fontSize: fontSize, useResponsiveSize: true, color: AppColors.grey400),
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
              color: AppColors.grey300.withOpacity(0.25),
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

class _TopStat extends StatelessWidget {
  const _TopStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          AppText.smd(value, fontSize: 36 / 2, color: AppColors.grey500),
          SizedBox(height: 2.h),
          AppText.rg(label, fontSize: 14 / 2, color: AppColors.grey300),
        ],
      ),
    );
  }
}

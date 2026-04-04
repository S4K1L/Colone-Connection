import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/controller/plan_route_controller.dart';
import 'package:flutter_extension/data/model/route_stop_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/route_flow_header.dart';
import 'package:flutter_extension/views/base/route_stats_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlanRouteScreen extends StatefulWidget {
  const PlanRouteScreen({super.key});

  @override
  State<PlanRouteScreen> createState() => _PlanRouteScreenState();
}

class _PlanRouteScreenState extends State<PlanRouteScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(PlanRouteController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<PlanRouteController>()) {
      Get.delete<PlanRouteController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green25,
      body: GetBuilder<PlanRouteController>(
        builder: (PlanRouteController c) {
          switch (c.stage) {
            case RouteFlowStage.planning:
              return _PlanningRouteView(c: c);
            case RouteFlowStage.nextStop:
            case RouteFlowStage.navigating:
              return _ActiveRouteMapView(c: c);
          }
        },
      ),
    );
  }
}

class _PlanningRouteView extends StatelessWidget {
  const _PlanningRouteView({required this.c});

  final PlanRouteController c;

  @override
  Widget build(BuildContext context) {
    final double listH = (c.stops.length * 92.h).clamp(92.h, 520.h);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RouteFlowHeader(
            onBack: () => Get.back(),
            title: 'Planning Route',
            subtitle: '${c.activeColonyCount} Colonies Active',
          ),
          RouteStatsCard(
            items: <RouteStatItem>[
              RouteStatItem(value: c.planningDistanceLabel, label: 'Distance'),
              RouteStatItem(
                value: c.planningDurationLabel,
                label: 'Duration',
              ),
              RouteStatItem(
                value: '${c.totalRouteCustomers}',
                label: 'Customer',
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      height: 200.h,
                      child: c.hasMapsKey
                          ? GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: c.stops.isNotEmpty
                                    ? c.stops.first.position
                                    : HomeController.center,
                                zoom: 12.5,
                              ),
                              markers: c.markers,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              onMapCreated: c.onMapCreated,
                            )
                          : Container(
                              color: AppColors.grey50,
                              alignment: Alignment.center,
                              child: const AppText.rg(
                                'Map unavailable',
                                fontSize: 13,
                                color: AppColors.grey300,
                                useResponsiveSize: true,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AppText.smd(
                        'Route Order',
                        fontSize: 16,
                        color: AppColors.grey500,
                        useResponsiveSize: true,
                      ),
                      AppText.rg(
                        'Drag to reorder',
                        fontSize: 12,
                        color: AppColors.grey300,
                        useResponsiveSize: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: listH,
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: c.stops.length,
                      onReorder: c.onReorder,
                      itemBuilder: (BuildContext context, int index) {
                        final RouteStopModel stop = c.stops[index];
                        return _RouteOrderTile(
                          key: ValueKey<String>(stop.id),
                          index: index,
                          stop: stop,
                          onRemove: () => c.removeStop(stop.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: c.stops.isEmpty ? null : c.startNavigation,
                borderRadius: BorderRadius.circular(16.r),
                child: Ink(
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        Color(0xFF408E1A),
                        Color(0xFF17B85F),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.navigation_rounded,
                        color: AppColors.white,
                        size: 22.w,
                      ),
                      SizedBox(width: 10.w),
                      const AppText.smd(
                        'Start Navigation',
                        fontSize: 16,
                        color: AppColors.white,
                        useResponsiveSize: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteOrderTile extends StatelessWidget {
  const _RouteOrderTile({
    super.key,
    required this.index,
    required this.stop,
    required this.onRemove,
  });

  final int index;
  final RouteStopModel stop;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final int order = index + 1;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.grey50),
          ),
          child: Row(
            children: <Widget>[
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: AppColors.grey200,
                    size: 26.w,
                  ),
                ),
              ),
              Container(
                width: 32.w,
                height: 32.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.green500,
                  shape: BoxShape.circle,
                ),
                child: AppText.smd(
                  '$order',
                  fontSize: 14,
                  color: AppColors.white,
                  useResponsiveSize: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppText.smd(
                        stop.colonyName,
                        fontSize: 15,
                        color: AppColors.grey500,
                        useResponsiveSize: true,
                      ),
                      SizedBox(height: 4.h),
                      AppText.rg(
                        '${stop.region} • ${stop.customers} customers',
                        fontSize: 12,
                        color: AppColors.grey300,
                        useResponsiveSize: true,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.errorColor,
                  size: 22.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveRouteMapView extends StatelessWidget {
  const _ActiveRouteMapView({required this.c});

  final PlanRouteController c;

  @override
  Widget build(BuildContext context) {
    final RouteStopModel? target = c.currentTarget;
    final bool navigating = c.stage == RouteFlowStage.navigating;

    final List<RouteStatItem> stats = navigating
        ? <RouteStatItem>[
            RouteStatItem(
              value: c.navigatingDistanceLabel,
              label: 'Distance',
            ),
            RouteStatItem(
              value: c.navigatingEtaLabel,
              label: 'ETA',
            ),
          ]
        : <RouteStatItem>[
            RouteStatItem(
              value: c.planningDistanceLabel,
              label: 'Distance',
            ),
            RouteStatItem(
              value: c.planningDurationLabel,
              label: 'ETA',
            ),
          ];

    String title;
    String? subtitle;
    String? trailing;
    if (navigating && target != null) {
      title = '${target.shortMapLabel} Colony';
      subtitle = target.colonyName;
      trailing = target.region;
    } else if (target != null) {
      title = 'Next Stop';
      subtitle = target.colonyName;
      trailing = target.region;
    } else {
      title = 'Route';
      subtitle = null;
      trailing = null;
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (c.hasMapsKey)
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: target?.position ?? HomeController.center,
              zoom: navigating ? 15 : 13.5,
            ),
            markers: c.markers,
            polylines: navigating ? c.buildPolylines() : <Polyline>{},
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: c.onMapCreated,
          )
        else
          Container(color: AppColors.grey50),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RouteFlowHeader(
                onBack: c.onHeaderBack,
                title: title,
                subtitle: subtitle,
                trailing: trailing,
              ),
              RouteStatsCard(items: stats),
              const Spacer(),
              _RouteBottomPanel(
                visited: c.visitedColoniesCount,
                total: c.stops.length,
                showNavigate: !navigating,
                onAddNote: c.onAddNote,
                onMarkVisited: c.markVisited,
                onNavigate: c.goToNavigating,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteBottomPanel extends StatelessWidget {
  const _RouteBottomPanel({
    required this.visited,
    required this.total,
    required this.showNavigate,
    required this.onAddNote,
    required this.onMarkVisited,
    required this.onNavigate,
  });

  final int visited;
  final int total;
  final bool showNavigate;
  final VoidCallback onAddNote;
  final VoidCallback onMarkVisited;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppText.rg(
            '$visited of $total colonies visited',
            fontSize: 14,
            color: AppColors.grey400,
            textAlign: TextAlign.center,
            useResponsiveSize: true,
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _SquareAction(
                icon: Icons.note_alt_outlined,
                iconColor: const Color(0xFFE8A23C),
                label: 'Add Note',
                onTap: onAddNote,
              ),
              _SquareAction(
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.green500,
                label: 'Mark Visited',
                onTap: onMarkVisited,
              ),
              if (showNavigate)
                _SquareAction(
                  icon: Icons.navigation_rounded,
                  iconColor: const Color(0xFF4285F4),
                  label: 'Navigate',
                  onTap: onNavigate,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: SizedBox(
        width: 92.w,
        child: Column(
          children: <Widget>[
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.grey50),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.grey300.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 28.w),
            ),
            SizedBox(height: 8.h),
            AppText.rg(
              label,
              fontSize: 11,
              color: AppColors.grey400,
              textAlign: TextAlign.center,
              maxLines: 2,
              useResponsiveSize: true,
            ),
          ],
        ),
      ),
    );
  }
}

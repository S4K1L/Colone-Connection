import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/customer_detail_controller.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/util/app_svg_paths.dart';
import 'package:flutter_extension/views/base/app_svg_icon.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerDetailAppBar extends StatelessWidget {
  const CustomerDetailAppBar({
    super.key,
    required this.args,
    required this.tabIndex,
    required this.onTab,
  });

  final CustomerDetailArgs args;
  final int tabIndex;
  final ValueChanged<int> onTab;

  static const List<String> _labels = <String>[
    'Contact',
    'Notes',
    'Machinery',
    'Visit History',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 12.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppText.smd(
                      args.name,
                      fontSize: 20,
                      color: AppColors.white,
                      useResponsiveSize: true,
                    ),
                    SizedBox(height: 4.h),
                    AppText.rg(
                      args.role,
                      fontSize: 13,
                      color: AppColors.white.withValues(alpha: 0.9),
                      useResponsiveSize: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(_labels.length, (int i) {
                final bool selected = tabIndex == i;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Material(
                    color: selected
                        ? const Color(0xFF1B8E3A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    child: InkWell(
                      onTap: () => onTab(i),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        child: AppText.smd(
                          _labels[i],
                          fontSize: 12,
                          color: selected
                              ? AppColors.white
                              : AppColors.white.withValues(alpha: 0.88),
                          useResponsiveSize: true,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerDetailBottomBar extends StatelessWidget {
  const CustomerDetailBottomBar({super.key});

  static const Color _barTint = Color(0xFFEEF8EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: _barTint,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: const Border(
          top: BorderSide(color: AppColors.green600, width: 1.5),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _BottomActionCard(
              svgPath: AppSvgPaths.success,
              circleColor: AppColors.green500,
              iconSize: 20.w,
              label: 'Mark Visited',
              onTap: () => Get.find<CustomerDetailController>().markVisited(),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _BottomActionCard(
              svgPath: AppSvgPaths.navigate,
              circleColor: const Color(0xFF1E6FE6),
              iconSize: 16.w,
              label: 'Navigate',
              onTap: () =>
                  Get.find<CustomerDetailController>().navigateToCustomer(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionCard extends StatelessWidget {
  const _BottomActionCard({
    required this.svgPath,
    required this.circleColor,
    required this.iconSize,
    required this.label,
    required this.onTap,
  });

  final String svgPath;
  final Color circleColor;
  final double iconSize;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: AppSvgIcon(
                  svgPath,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
              SizedBox(height: 8.h),
              AppText.smd(
                label,
                fontSize: 13,
                color: AppColors.grey500,
                textAlign: TextAlign.center,
                useResponsiveSize: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

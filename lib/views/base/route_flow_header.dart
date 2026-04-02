import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Green gradient bar: circular back, title, subtitle, optional trailing.
class RouteFlowHeader extends StatelessWidget {
  const RouteFlowHeader({
    super.key,
    required this.onBack,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final VoidCallback onBack;
  final String title;
  final String? subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 16.w, 20.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Color(0xFF408E1A),
            Color(0xFF17B85F),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.white,
                size: 18.w,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText.smd(
                  title,
                  fontSize: 20,
                  color: AppColors.white,
                  useResponsiveSize: true,
                ),
                if (subtitle != null) ...<Widget>[
                  SizedBox(height: 4.h),
                  AppText.rg(
                    subtitle!,
                    fontSize: 13,
                    color: AppColors.white80,
                    useResponsiveSize: true,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: AppText.rg(
                trailing!,
                fontSize: 13,
                color: AppColors.white,
                useResponsiveSize: true,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single notification card: pastel dot, title, body, time, dismiss.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.accentColor,
    required this.onDismiss,
  });

  final String title;
  final String body;
  final String timeAgo;
  final Color accentColor;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText.smd(
                  title,
                  fontSize: 15,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
                SizedBox(height: 6.h),
                AppText.rg(
                  body,
                  fontSize: 13,
                  color: AppColors.grey400,
                  useResponsiveSize: true,
                ),
                SizedBox(height: 8.h),
                AppText.rg(
                  timeAgo,
                  fontSize: 12,
                  color: AppColors.grey200,
                  useResponsiveSize: true,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: AppColors.grey50,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onDismiss,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  Icons.close_rounded,
                  size: 18.w,
                  color: AppColors.grey400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/notifications_controller.dart';
import 'package:flutter_extension/model/app_notification_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/notification_tile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      builder: (NotificationsController c) {
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _NotificationsBody(controller: c),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    final double headerH = 108.h;
    final double overlap = 28.h;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerH,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const AppText.smd(
                  'Notifications',
                  fontSize: 26,
                  color: AppColors.white,
                  useResponsiveSize: true,
                ),
                SizedBox(height: 6.h),
                AppText.rg(
                  controller.subtitleText,
                  fontSize: 15,
                  color: AppColors.white80,
                  useResponsiveSize: true,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: headerH - overlap,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26.r),
                topRight: Radius.circular(26.r),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.green500,
                    ),
                  )
                : controller.hasNotifications
                ? ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      10.h,
                      16.w,
                      24.h,
                    ),
                    itemCount: controller.notifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      final AppNotificationModel n =
                          controller.notifications[index];
                      return NotificationTile(
                        title: n.title,
                        body: n.content,
                        timeAgo: n.timeAgo,
                        accentColor: n.accentColor,
                        onDismiss: () => controller.dismissNotification(n.id),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.w),
                      child: const AppText.rg(
                        'You’re all caught up.',
                        fontSize: 15,
                        color: AppColors.grey300,
                        textAlign: TextAlign.center,
                        useResponsiveSize: true,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

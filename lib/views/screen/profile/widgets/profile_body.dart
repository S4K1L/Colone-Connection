import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/model/user_profile_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/util/app_svg_paths.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/profile/widgets/profile_card.dart';
import 'package:flutter_extension/views/screen/profile/widgets/settings_icon_widgets.dart';
import 'package:flutter_extension/views/screen/profile/widgets/settings_nav_row.dart';
import 'package:flutter_extension/views/screen/profile/widgets/settings_toggle_row.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key, required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final double headerH = 118.h;
    final double overlap = 28.h;
    final UserProfileModel p = controller.profile;

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
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 36.h),
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
              children: <Widget>[
                const AppText.smd(
                  'Profile & Settings',
                  fontSize: 24,
                  color: AppColors.white,
                  useResponsiveSize: true,
                ),
                SizedBox(height: 6.h),
                const AppText.rg(
                  'Customize your profile',
                  fontSize: 14,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ProfileCard(
                    profile: p,
                    onEditProfile: controller.onEditProfile,
                  ),
                  SizedBox(height: 22.h),
                  //TODO: add push notifications on/off by restapi
                  SettingsToggleRow(
                    svgPath: AppSvgPaths.alert,
                    label: 'Push Notifications',
                    value: controller.pushNotificationsEnabled,
                    onChanged: controller.setPushNotifications,
                  ),
                  SettingsNavRow(
                    svgPath: AppSvgPaths.lock,
                    label: 'Change Password',
                    onTap: controller.onChangePassword,
                  ),
                  //TODO: add terms and policies and about us
                  SettingsNavRow(
                    svgPath: AppSvgPaths.success,
                    label: 'Terms & Policies',
                    onTap: controller.onTermsAndPolicies,
                  ),
                  //TODO: add terms and policies and about us
                  SettingsNavRow(
                    label: 'About Us',
                    onTap: controller.onAboutUs,
                    background: false,
                    leadingIcon: const SettingsPngIconBox(
                      asset: 'assets/images/logo.png',
                      background: false,
                    ),
                  ),
                  //TODO: add delete account by restapi
                  SettingsNavRow(
                    svgPath: AppSvgPaths.delete,
                    label: 'Delete Account',
                    onTap: controller.onDeleteAccount,
                    danger: false,
                    background: false,
                  ),
                  SettingsNavRow(
                    
                    svgPath: AppSvgPaths.logout,
                    label: 'Log Out',
                    onTap: controller.onLogOut,
                    background: false,
                    danger: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

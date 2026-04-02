import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/data/model/user_profile_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/util/app_svg_paths.dart';
import 'package:flutter_extension/views/base/app_svg_icon.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (ProfileController c) {
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(
            bottom: false,
            child: _ProfileBody(controller: c),
          ),
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.controller});

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
                  _ProfileCard(
                    profile: p,
                    onEditProfile: controller.onEditProfile,
                  ),
                  SizedBox(height: 22.h),
                  _SettingsToggleRow(
                    svgPath: AppSvgPaths.alert,
                    label: 'Push Notifications',
                    value: controller.pushNotificationsEnabled,
                    onChanged: controller.setPushNotifications,
                  ),
                  _SettingsNavRow(
                    svgPath: AppSvgPaths.lock,
                    label: 'Change Password',
                    onTap: controller.onChangePassword,
                  ),
                  _SettingsNavRow(
                    svgPath: AppSvgPaths.success,
                    label: 'Terms & Policies',
                    onTap: controller.onTermsAndPolicies,
                  ),
                  _SettingsNavRow(
                    label: 'About Us',
                    onTap: controller.onAboutUs,
                    background: false,
                    leadingIcon: const _SettingsPngIconBox(
                      asset: 'assets/images/logo.png',
                      background: false,
                    ),
                  ),
                  _SettingsNavRow(
                    svgPath: AppSvgPaths.delete,
                    label: 'Delete Account',
                    onTap: controller.onDeleteAccount,
                    danger: false,
                    background: false,
                  ),
                  _SettingsNavRow(
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.onEditProfile,
  });

  final UserProfileModel profile;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.grey100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppSvgIcon(
                    AppSvgPaths.profile,
                    size: 34.w,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: AppText.smd(
                            profile.displayName,
                            fontSize: 18,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                        ),
                        if (profile.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: const AppText.smd(
                              'Active',
                              fontSize: 11,
                              color: AppColors.green700,
                              useResponsiveSize: true,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    AppText.rg(
                      profile.jobTitle,
                      fontSize: 14,
                      color: AppColors.grey300,
                      useResponsiveSize: true,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: AppText.rg(
                        'ID: ${profile.employeeId}',
                        fontSize: 12,
                        color: AppColors.grey400,
                        useResponsiveSize: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: AppColors.grey50),
          ),
          _ContactLine(
            svgPath: AppSvgPaths.mail,
            text: profile.email,
          ),
          SizedBox(height: 12.h),
          _ContactLine(
            svgPath: AppSvgPaths.map,
            text: profile.phone,
          ),
          SizedBox(height: 12.h),
          _ContactLine(
            svgPath: AppSvgPaths.colone,
            text: profile.company,
          ),
          SizedBox(height: 18.h),
          Material(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              onTap: onEditProfile,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: const AppText.smd(
                  'Edit Profile',
                  fontSize: 15,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.svgPath, required this.text});

  final String svgPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSvgIcon(
          svgPath,
          size: 20.w,
          color: AppColors.grey300,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AppText.rg(
            text,
            fontSize: 13,
            color: AppColors.grey400,
            useResponsiveSize: true,
          ),
        ),
      ],
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.svgPath,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String svgPath;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Row(
            children: <Widget>[
              _SettingsIconBox(svgPath: svgPath, background: true),
              SizedBox(width: 14.w),
              Expanded(
                child: AppText.smd(
                  label,
                  fontSize: 15,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.green500,
                activeThumbColor: AppColors.white,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    this.svgPath,
    this.leadingIcon,
    required this.label,
    required this.onTap,
    this.background = true,
    this.danger = false,
  });

  final String? svgPath;
  final Widget? leadingIcon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool background;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        danger ? AppColors.errorColor : AppColors.grey500;
    final Color iconColor =
        danger ? AppColors.errorColor : AppColors.grey400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Row(
            children: <Widget>[
              (leadingIcon ??
                      _SettingsIconBox(
                        svgPath: svgPath!,
                        iconColor: iconColor,
                        background: background,
                      )),
              SizedBox(width: 14.w),
              Expanded(
                child: AppText.smd(
                  label,
                  fontSize: 15,
                  color: textColor,
                  useResponsiveSize: true,
                ),
              ),
              ],
          ),
        ),
      ),
    );
  }
}

class _SettingsIconBox extends StatelessWidget {
  const _SettingsIconBox({
    required this.svgPath,
    this.iconColor,
    this.background = false,
  });

  final String svgPath;
  final Color? iconColor;
  final bool background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: background ? AppColors.grey50 : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        svgPath,
        size: background ? 22.w : 40.w,
        color: iconColor ?? AppColors.grey400,
      ),
    );
  }
}

class _SettingsPngIconBox extends StatelessWidget {
  const _SettingsPngIconBox({
    required this.asset,
    this.background = false,
  });

  final String asset;
  final bool background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: background ? AppColors.grey50 : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        width: 40.w,
        height: 40.w,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.apartment_rounded,
            size: 22.w,
            color: AppColors.grey400,
          );
        },
      ),
    );
  }
}

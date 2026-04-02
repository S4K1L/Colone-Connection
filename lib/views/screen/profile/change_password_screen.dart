import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/util/app_svg_paths.dart';
import 'package:flutter_extension/views/base/app_svg_icon.dart';
import 'package:flutter_extension/views/base/app_primary_button.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/route_flow_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (ProfileController c) {
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: <Widget>[
                RouteFlowHeader(
                  onBack: () => Get.back(),
                  title: 'Change Password',
                ),
                Positioned.fill(
                  top: 84.h,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(26.r),
                        topRight: Radius.circular(26.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Container(
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
                                  AppSvgPaths.lock,
                                  size: 24.w,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          AppText.rg(
                            'Old Password',
                            fontSize: 14,
                            color: AppColors.grey400,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          _PasswordFieldCard(
                            controller: _oldPasswordController,
                            obscureText: _obscureOld,
                            onToggleVisibility: () =>
                                setState(() => _obscureOld = !_obscureOld),
                          ),
                          SizedBox(height: 14.h),
                          AppText.rg(
                            'New Password',
                            fontSize: 14,
                            color: AppColors.grey400,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          _PasswordFieldCard(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            onToggleVisibility: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                          SizedBox(height: 14.h),
                          AppText.rg(
                            'Confirm Password',
                            fontSize: 14,
                            color: AppColors.grey400,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          _PasswordFieldCard(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            onToggleVisibility: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          const Spacer(),
                          AppPrimaryButton(
                            title: 'Save Now',
                            onPressed: () {
                              c.updatePassword(
                                oldPassword: _oldPasswordController.text,
                                newPassword: _newPasswordController.text,
                                confirmPassword:
                                    _confirmPasswordController.text,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PasswordFieldCard extends StatelessWidget {
  const _PasswordFieldCard({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        // border: Border.all(color: AppColors.grey100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: SizedBox(
        height: 54.h,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          cursorColor: AppColors.green500,
          style: TextStyle(color: AppColors.grey300, fontSize: 15.sp),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 16.h,
            ),
            hintText: 'Password',
            hintStyle: TextStyle(color: AppColors.grey200, fontSize: 15.sp),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 8.w),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.grey200,
                size: 20.w,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 24.h,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.grey200,
                size: 20.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/auth_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_primary_button.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/auth_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return GetBuilder<AuthController>(
      builder: (auth) => Scaffold(
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: Form(
            key: auth.resetFormKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back, size: 24.w, color: AppColors.grey500),
                    ),
                  ),
                  SizedBox(height: 46.h),
                  Container(
                    width: 62.w,
                    height: 62.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(31.r),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[AppColors.green700, AppColors.green500],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.green300.withOpacity(0.35),
                          blurRadius: 16.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/lock.svg',
                        width: 24.w,
                        height: 24.w,
                        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  const AppText.smd(
                    'Reset Password',
                    fontSize: 24,
                    color: AppColors.grey500,
                  ),
                  SizedBox(height: 8.h),
                  const AppText.rg(
                    'Create a strong new  password of your account',
                    fontSize: 13,
                    color: AppColors.grey300,
                  ),
                  SizedBox(height: 28.h),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppText.md(
                      'New Password',
                      fontSize: 13,
                      color: AppColors.grey500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AppPasswordField(
                    controller: auth.newPasswordController,
                    hintText: 'Enter new password',
                    textInputAction: TextInputAction.next,
                    validator: auth.newPasswordValidator,
                    onChanged: auth.onResetPasswordChanged,
                  ),
                  if (auth.newPasswordController.text.isNotEmpty ||
                      auth.confirmPasswordController.text.isNotEmpty) ...<Widget>[
                    SizedBox(height: 10.h),
                    Row(
                      children: <Widget>[
                        const AppText.md(
                          'Password Strength',
                          fontSize: 12,
                          color: AppColors.grey400,
                        ),
                        const Spacer(),
                        AppText.md(
                          auth.strengthText,
                          fontSize: 12,
                          color: auth.strengthScore <= 2
                              ? AppColors.errorColor
                              : AppColors.green600,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: List<Widget>.generate(5, (int i) {
                        final bool active = i < auth.strengthScore;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i == 4 ? 0 : 4.w),
                            height: 4.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.r),
                              color: active
                                  ? (auth.strengthScore <= 2
                                        ? AppColors.errorColor
                                        : AppColors.green500)
                                  : AppColors.grey100,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.green25,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.grey100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const AppText.md(
                            'Password must contain:',
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                          SizedBox(height: 8.h),
                          _RuleRow(label: 'At least 8 characters', passed: auth.hasMinLength),
                          _RuleRow(label: 'One uppercase letter', passed: auth.hasUpperCase),
                          _RuleRow(label: 'One lowercase letter', passed: auth.hasLowerCase),
                          _RuleRow(label: 'One number', passed: auth.hasNumber),
                          _RuleRow(label: 'One special character', passed: auth.hasSpecial),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppText.md(
                      'Confirm Password',
                      fontSize: 13,
                      color: AppColors.grey500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AppPasswordField(
                    controller: auth.confirmPasswordController,
                    hintText: 'Re-enter new password',
                    validator: auth.confirmPasswordValidator,
                    onChanged: auth.onResetPasswordChanged,
                  ),
                  const Spacer(),
                  AppPrimaryButton(
                    title: 'Update Password',
                    isLoading: auth.resetLoading,
                    onPressed: authController.resetPassword,
                  ),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.passed});

  final String label;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        children: <Widget>[
          AppText.rg(
            passed ? '✓' : '✕',
            fontSize: 12,
            color: passed ? AppColors.green600 : AppColors.grey300,
          ),
          SizedBox(width: 8.w),
          AppText.rg(
            label,
            fontSize: 12,
            color: passed ? AppColors.green600 : AppColors.grey400,
          ),
        ],
      ),
    );
  }
}

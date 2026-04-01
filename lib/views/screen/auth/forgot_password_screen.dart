import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/auth_controller.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_primary_button.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/auth_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return GetBuilder<AuthController>(
      builder: (auth) => Scaffold(
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: Form(
            key: auth.forgotFormKey,
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
                  SizedBox(height: 90.h),
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
                  SizedBox(height: 22.h),
                  const AppText.smd(
                    'Forgot Password',
                    fontSize: 24,
                    color: AppColors.grey500,
                  ),
                  SizedBox(height: 8.h),
                  const AppText.rg(
                    "No worries, we’ll send you reset instructions",
                    fontSize: 14,
                    color: AppColors.grey300,
                  ),
                  SizedBox(height: 38.h),
                  AppEmailField(
                    controller: auth.forgotEmailController,
                    validator: auth.emailValidator,
                  ),
                  SizedBox(height: 14.h),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppText.rg(
                      'Enter your registered email or phone. You will receive a 6 digit\ncode to create a new password.',
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                  const Spacer(),
                  AppPrimaryButton(
                    title: 'Send OTP',
                    isLoading: auth.forgotLoading,
                    onPressed: authController.sendOtp,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const AppText.rg(
                        'Remember your password? ',
                        fontSize: 14,
                        color: AppColors.grey200,
                      ),
                      GestureDetector(
                        onTap: () => Get.offNamed(AppRoutes.loginScreen),
                        child: const AppText.md(
                          'Back to Login',
                          fontSize: 14,
                          color: AppColors.green600,
                        ),
                      ),
                    ],
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

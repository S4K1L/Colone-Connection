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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return GetBuilder<AuthController>(
      builder: (auth) => Scaffold(
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: Form(
            key: auth.loginFormKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 2),
                  Container(
                    width: 62.w,
                    height: 62.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
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
                        'assets/icons/hi.svg',
                        width: 24.w,
                        height: 24.w,
                        colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  const AppText.smd('Welcome Back', fontSize: 24, color: AppColors.grey500),
                  SizedBox(height: 8.h),
                  const AppText.rg(
                    'Sign in to continue to RouteOptima',
                    fontSize: 14,
                    color: AppColors.grey300,
                  ),
                  SizedBox(height: 38.h),
                  AppEmailField(
                    controller: auth.loginEmailController,
                    validator: auth.emailValidator,
                  ),
                  SizedBox(height: 12.h),
                  AppPasswordField(
                    controller: auth.loginPasswordController,
                    validator: auth.loginPasswordValidator,
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.forgotPasswordScreen),
                      child: const AppText.md(
                        'Forgot Password?',
                        fontSize: 14,
                        color: AppColors.green600,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  AppPrimaryButton(
                    title: 'Sign In',
                    isLoading: auth.loginLoading,
                    onPressed: authController.login,
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.createAccountScreen),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AppText.rg(
                          "Don't have an account? ",
                          fontSize: 14,
                          color: AppColors.grey200,
                        ),
                        AppText.md('Sign Up', fontSize: 14, color: AppColors.green600),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

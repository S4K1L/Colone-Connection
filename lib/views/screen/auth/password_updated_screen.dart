import 'package:flutter/material.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_primary_button.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
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
              const Spacer(flex: 3),
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
                      color: AppColors.green300.withValues(alpha: 0.35),
                      blurRadius: 16.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/success.svg',
                    width: 24.w,
                    height: 24.w,
                    colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              const AppText.smd(
                'Password\nSuccessfully Updated',
                fontSize: 38 / 2,
                textAlign: TextAlign.center,
                height: 1.15,
                color: AppColors.grey500,
              ),
              SizedBox(height: 10.h),
              const AppText.rg(
                'Your password has been changed successfully. You can\nnow login with your new password.',
                fontSize: 12,
                textAlign: TextAlign.center,
                color: AppColors.grey300,
              ),
              const Spacer(flex: 5),
              AppPrimaryButton(
                title: 'Back to Login',
                onPressed: () => Get.offAllNamed(AppRoutes.loginScreen),
              ),
              SizedBox(height: 18.h),
            ],
          ),
        ),
      ),
    );
  }
}

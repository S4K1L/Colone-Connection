import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/util/app_constants.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// About dialog: green header + white body, logo, app name, version — matches profile/notifications chrome.
class AboutUsSheet extends StatelessWidget {
  const AboutUsSheet({super.key});

  static const String _logoAsset = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          margin: EdgeInsets.only(top: 12.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: Offset(0, -4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 20.h),
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
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const AppText.smd(
                      'About Us',
                      fontSize: 20,
                      color: AppColors.white,
                      useResponsiveSize: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: Get.back,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 24.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 8.h),
                    _Logo(asset: _logoAsset),
                    SizedBox(height: 20.h),
                    AppText.smd(
                      AppConstants.APP_NAME,
                      fontSize: 20,
                      color: AppColors.grey500,
                      textAlign: TextAlign.center,
                      useResponsiveSize: true,
                    ),
                    SizedBox(height: 8.h),
                    AppText.rg(
                      'Field service & colony management',
                      fontSize: 14,
                      color: AppColors.grey300,
                      textAlign: TextAlign.center,
                      useResponsiveSize: true,
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: AppText.rg(
                        'Version ${AppConstants.APP_VERSION}',
                        fontSize: 13,
                        color: AppColors.green700,
                        useResponsiveSize: true,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    AppText.rg(
                      'We help teams plan routes, visit colonies, and stay on top of customer relationships.',
                      fontSize: 13,
                      color: AppColors.grey400,
                      textAlign: TextAlign.center,
                      height: 1.45,
                      useResponsiveSize: true,
                    ),
                    SizedBox(height: 20.h),
                    AppText.rg(
                      '© ${DateTime.now().year} AquaTech Solutions Pvt. Ltd.',
                      fontSize: 12,
                      color: AppColors.grey200,
                      textAlign: TextAlign.center,
                      useResponsiveSize: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.grey50),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Image.asset(
        asset,
        height: 88.h,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return SizedBox(
            height: 88.h,
            width: 88.w,
            child: Icon(
              Icons.apartment_rounded,
              size: 56.w,
              color: AppColors.green500,
            ),
          );
        },
      ),
    );
  }
}

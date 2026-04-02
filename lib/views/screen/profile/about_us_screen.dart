import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/util/app_svg_paths.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/app_svg_icon.dart';
import 'package:flutter_extension/views/base/route_flow_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green25,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            RouteFlowHeader(
              onBack: () => Get.back(),
              title: 'About Us',
            ),
            Expanded(
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
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppSvgIcon(
                            AppSvgPaths.alert,
                            size: 18.w,
                            color: AppColors.green600,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: AppText.rg(
                              'We are committed to providing innovative and user-friendly digital solutions that help businesses grow and connect with their audiences. Our goal is to deliver high-quality products and services that combine efficiency, technology, and reliability. By focusing on user experience and modern design standards, we strive to create an engaging and enjoyable app experience. Our team continuously works to improve our services to meet the evolving needs of our users and clients.',
                              fontSize: 12,
                              color: AppColors.grey400,
                              height: 1.35,
                              useResponsiveSize: true,
                            ),
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
  }
}


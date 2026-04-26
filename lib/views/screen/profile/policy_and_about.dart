import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/route_flow_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TermsPoliciesScreen extends StatefulWidget {
  final String? title;
  final String? endPoint;
  const TermsPoliciesScreen({super.key, this.title, this.endPoint});

  @override
  State<TermsPoliciesScreen> createState() => _TermsPoliciesScreenState();
}

class _TermsPoliciesScreenState extends State<TermsPoliciesScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    if (widget.endPoint != null) {
      profileController.getTermsAndPolicies(widget.endPoint!);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green25,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            RouteFlowHeader(
              onBack: () => Get.back(),
              title: widget.title ?? '',
            ),
            Positioned(
              top: 84.h,
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
                ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/logo.png',
                              width: 32.w,
                            height: 32.w,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 10.h),
                          const Expanded(
                            child: AppText.rg(
                              'By using our platform, you agree to comply with our terms and policies designed to ensure a safe and reliable experience for all users. We respect your privacy and are committed to protecting your personal information. Any data collected through our platform is used only to improve our services and provide a better user experience. Users are expected to use the platform responsibly and abide by any activities that harm the system or other users. We reserve the right to update these terms and policies when necessary to maintain service quality and compliance with applicable regulations.',
                              fontSize: 18,
                              color: AppColors.grey300,
                              useResponsiveSize: true,
                              textAlign: TextAlign.justify,
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

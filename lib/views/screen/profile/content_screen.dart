import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/util/api_constant.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/route_flow_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class ContentScreen extends StatefulWidget {
  final String? title;
  final String? endPoint;
  const ContentScreen({super.key, this.title, this.endPoint});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    if (widget.endPoint != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileController.getTermsAndPolicies(widget.endPoint!);
      });
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
                child: GetBuilder<ProfileController>(
                  builder: (ProfileController c) {
                    if (c.isContentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.green500,
                        ),
                      );
                    }

                    final items = widget.endPoint == ApiConstant.GET_TERMS_AND_POLICIES
                        ? c.termsAndPolicies
                        : c.aboutUs;

                    if (items.isEmpty) {
                      return const Center(child: AppText.rg('No content available.'));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: HtmlWidget(
                            item.text,
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grey500,
                              height: 1.5,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

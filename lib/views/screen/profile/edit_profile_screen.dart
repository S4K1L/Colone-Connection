import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_primary_button.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/route_flow_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;

  static const String _avatarAsset = 'assets/images/placeholder.jpg';

  @override
  void initState() {
    super.initState();
    final ProfileController c = Get.find<ProfileController>();
    _fullNameController = TextEditingController(text: c.profile.displayName);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
                  title: 'Edit Profile',
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
                            child: SizedBox(
                              width: 98.w,
                              height: 98.w,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 98.w,
                                    height: 98.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF63D0C9),
                                        width: 3,
                                      ),
                                    ),
                                    padding: EdgeInsets.all(6.w),
                                    child: ClipOval(
                                      child: Image.asset(
                                        _avatarAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (BuildContext context, Object _, __) {
                                          return Container(
                                            color: const Color(0xFFE6F7FF),
                                            child: const Icon(
                                              Icons.person_rounded,
                                              color: Color(0xFF2D9CDB),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8.h,
                                    right: 8.w,
                                    child: Container(
                                      width: 30.w,
                                      height: 30.w,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2D9CDB),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 18,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          AppText.rg(
                            'Full Name',
                            fontSize: 13,
                            color: AppColors.grey400,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          _buildField(
                            controller: _fullNameController,
                            keyboardType: TextInputType.name,
                          ),
                          const Spacer(),
                          AppPrimaryButton(
                            title: 'Save Now',
                            height: 48,
                            borderRadius: 14,
                            onPressed: () {
                              c.updateProfileName(_fullNameController.text);
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

  Widget _buildField({
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey100),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.grey300.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: SizedBox(
        height: 54.h,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          cursorColor: AppColors.green500,
          style: TextStyle(color: AppColors.grey300, fontSize: 15.sp),
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 16.h,
            ),
          ),
        ),
      ),
    );
  }
}

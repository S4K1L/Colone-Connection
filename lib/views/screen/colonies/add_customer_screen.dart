import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/add_customer_controller.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_flow_header.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/form_map_preview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddCustomerScreen extends StatelessWidget {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddCustomerArgs args = Get.arguments is AddCustomerArgs
        ? Get.arguments as AddCustomerArgs
        : const AddCustomerArgs(colonyId: '0', colonyName: 'Colony');

    return GetBuilder<AddCustomerController>(
      init: AddCustomerController(),
      builder: (AddCustomerController c) {
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ColonyFlowHeader(
                  onBack: () => Get.back(),
                  title: 'Add Customer',
                  subtitle: 'Add a new customer · ${args.colonyName}',
                ),
                if (c.isLoading)
                  const LinearProgressIndicator(color: AppColors.green500),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Image Picker
                          Center(
                            child: GestureDetector(
                              onTap: () => c.pickImage(),
                              child: Container(
                                width: 100.w,
                                height: 100.w,
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(50.r),
                                  border: Border.all(color: AppColors.grey100),
                                  image: c.imageFile != null
                                      ? DecorationImage(
                                          image: FileImage(c.imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: c.imageFile == null
                                    ? Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 32.sp,
                                        color: AppColors.grey300,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          const AppText.smd(
                            'Company Owner Name',
                            fontSize: 14,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: c.ownerNameCtrl,
                            decoration: _fieldDecoration('Write here'),
                          ),
                          SizedBox(height: 18.h),

                          const AppText.smd(
                            'Company Name',
                            fontSize: 14,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: c.companyNameCtrl,
                            decoration: _fieldDecoration('Write here'),
                          ),
                          SizedBox(height: 18.h),

                          const AppText.smd(
                            'Email Address',
                            fontSize: 14,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: c.emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _fieldDecoration('Enter email address'),
                          ),
                          SizedBox(height: 18.h),

                          const AppText.smd(
                            'Phone Number',
                            fontSize: 14,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: c.phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldDecoration('Enter phone number'),
                          ),
                          SizedBox(height: 18.h),

                          const AppText.smd(
                            'Alternate Phone',
                            fontSize: 14,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: c.alternatePhoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldDecoration('Enter phone number'),
                          ),
                          SizedBox(height: 18.h),

                          const AppText.smd(
                            'GPS Location',
                            fontSize: 14,
                            color: AppColors.grey500,
                            useResponsiveSize: true,
                          ),
                          SizedBox(height: 8.h),
                          const FormMapPreview(),
                          SizedBox(height: 28.h),

                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.grey500,
                                    side: const BorderSide(
                                      color: AppColors.grey100,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: const AppText.smd(
                                    'Cancel',
                                    fontSize: 15,
                                    color: AppColors.grey500,
                                    useResponsiveSize: true,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                flex: 6,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: c.isLoading
                                        ? null
                                        : () => c.saveCustomer(args.colonyId),
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Ink(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        gradient: const LinearGradient(
                                          colors: <Color>[
                                            Color(0xFF2EAD4B),
                                            Color(0xFF4BC76A),
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          const AppText.smd(
                                            'Save Now',
                                            fontSize: 15,
                                            color: AppColors.white,
                                            useResponsiveSize: true,
                                          ),
                                          SizedBox(width: 6.w),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: AppColors.white,
                                            size: 20.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey300, fontSize: 14.sp),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/colony_flow_header.dart';
import 'package:flutter_extension/views/screen/colonies/widgets/form_map_preview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController _ownerCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _phone2Ctrl = TextEditingController();

  @override
  void dispose() {
    _ownerCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _phone2Ctrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.grey300,
        fontSize: 14.sp,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
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

  @override
  Widget build(BuildContext context) {
    final AddCustomerArgs args = Get.arguments is AddCustomerArgs
        ? Get.arguments as AddCustomerArgs
        : const AddCustomerArgs(colonyId: '0', colonyName: 'Colony');

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
                      const AppText.smd(
                        'Company Owner Name',
                        fontSize: 14,
                        color: AppColors.grey500,
                        useResponsiveSize: true,
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _ownerCtrl,
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
                        controller: _companyCtrl,
                        decoration: _fieldDecoration('Write here'),
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
                        controller: _phoneCtrl,
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
                        controller: _phone2Ctrl,
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
                                padding: EdgeInsets.symmetric(vertical: 14.h),
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
                                onTap: () {
                                  Get.back();
                                  Get.snackbar(
                                    'Customers',
                                    'Customer saved (demo).',
                                  );
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Ink(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    gradient: const LinearGradient(
                                      colors: <Color>[
                                        Color(0xFF2EAD4B),
                                        Color(0xFF4BC76A),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
  }
}

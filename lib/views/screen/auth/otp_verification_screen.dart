import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_extension/controller/auth_controller.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_primary_button.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final AuthController _authController;

  String get _maskedEmail => _authController.maskedEmail;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    final dynamic args = Get.arguments;
    if (args is Map && args['maskedEmail'] is String) {
      _authController.maskedEmail = args['maskedEmail'] as String;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authController.otpFocusNode.requestFocus();
      _authController.tryReadClipboardOtp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (auth) {
        final String code = auth.otpController.text;
        final bool isCodeComplete = code.length == AuthController.otpLength;
        return Scaffold(
          backgroundColor: AppColors.green25,
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
                    'assets/icons/mail.svg',
                    width: 24.w,
                    height: 24.w,
                    colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              const AppText.smd(
                'Verify Your Email',
                fontSize: 24,
                color: AppColors.grey500,
              ),
              SizedBox(height: 8.h),
              const AppText.rg(
                "We've sent a verification code to",
                fontSize: 14,
                color: AppColors.grey300,
              ),
              SizedBox(height: 4.h),
              AppText.md(
                _maskedEmail,
                fontSize: 16,
                color: AppColors.grey500,
              ),
              SizedBox(height: 42.h),
              const AppText.md(
                'Enter verification code',
                fontSize: 14,
                color: AppColors.grey500,
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () => auth.otpFocusNode.requestFocus(),
                child: Stack(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(AuthController.otpLength, (int index) {
                        final String digit = index < code.length ? code[index] : '';
                        final bool isActive =
                            index == code.length && code.length < AuthController.otpLength;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Container(
                            width: 49.w,
                            height: 49.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.green25,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isActive ? AppColors.green500 : AppColors.grey100,
                                width: 1.w,
                              ),
                            ),
                            child: AppText.md(
                              digit,
                              fontSize: 20,
                              color: AppColors.grey500,
                            ),
                          ),
                        );
                      }),
                    ),
                    // Hidden input captures OTP typing, paste, and SMS autofill.
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: AutofillGroup(
                          child: TextField(
                            controller: auth.otpController,
                            focusNode: auth.otpFocusNode,
                            keyboardType: TextInputType.number,
                            autofillHints: const <String>[AutofillHints.oneTimeCode],
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(AuthController.otpLength),
                            ],
                            onChanged: auth.onOtpChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              const AppText.rg(
                "Didn't receive the code?",
                fontSize: 14,
                color: AppColors.grey300,
              ),
              SizedBox(height: 6.h),
              GestureDetector(
                onTap: auth.otpLoading ? null : auth.tryReadClipboardOtp,
                child: AppText.md(
                  'Resend Code',
                  fontSize: 14,
                  color: auth.otpLoading ? AppColors.grey200 : AppColors.green600,
                ),
              ),
              const Spacer(),
              AppPrimaryButton(
                title: 'Verify Code',
                isLoading: auth.otpLoading,
                onPressed: isCodeComplete ? auth.verifyOtp : null,
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => Get.offNamed(AppRoutes.forgotPasswordScreen),
                child: const AppText.rg(
                  'Change email address',
                  fontSize: 13,
                  color: AppColors.grey300,
                ),
              ),
              SizedBox(height: 28.h),
            ],
          ),
        ),
          ),
        );
      },
    );
  }
}

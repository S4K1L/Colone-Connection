import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/auth_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_primary_button.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/base/auth_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return GetBuilder<AuthController>(
      builder: (auth) => Scaffold(
        backgroundColor: AppColors.grey50,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 14.h),
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
                      child: Icon(Icons.person_add_alt_1, size: 28.w, color: AppColors.white),
                    ),
                    SizedBox(height: 14.h),
                    const AppText.smd('Create Account', fontSize: 34 / 2, color: AppColors.grey500),
                    SizedBox(height: 6.h),
                    const AppText.rg(
                      'Join Colony Connection Today',
                      fontSize: 14,
                      color: AppColors.grey300,
                    ),
                    SizedBox(height: 24.h),
                    _label('Full Name'),
                    SizedBox(height: 7.h),
                    TextFormField(
                      controller: auth.signupNameController,
                      validator: auth.fullNameValidator,
                      decoration: _fieldDecoration('John Smith', Icons.person_outline),
                    ),
                    SizedBox(height: 12.h),
                    _label('Work Email'),
                    SizedBox(height: 7.h),
                    TextFormField(
                      controller: auth.signupEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: auth.emailValidator,
                      decoration: _fieldDecoration('john@comapany.com', Icons.mail_outline),
                    ),
                    SizedBox(height: 12.h),
                    _label('Phone Number'),
                    SizedBox(height: 7.h),
                    TextFormField(
                      controller: auth.signupPhoneController,
                      keyboardType: TextInputType.phone,
                      validator: auth.phoneValidator,
                      decoration: _fieldDecoration('+1 (555) 000-0000', Icons.phone_outlined),
                    ),
                    SizedBox(height: 12.h),
                    _label('Password'),
                    SizedBox(height: 7.h),
                    AppPasswordField(
                      controller: auth.signupPasswordController,
                      hintText: 'Password',
                      textInputAction: TextInputAction.next,
                      validator: auth.newPasswordValidator,
                    ),
                    SizedBox(height: 12.h),
                    _label('Confirm Password'),
                    SizedBox(height: 7.h),
                    AppPasswordField(
                      controller: auth.signupConfirmPasswordController,
                      hintText: 'Password',
                      validator: auth.signupConfirmPasswordValidator,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (bool? v) => setState(() => _agreedToTerms = v ?? false),
                          side: const BorderSide(color: AppColors.grey200),
                          activeColor: AppColors.green600,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: RichText(
                              text: const TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: 'By signing up, you agree to our ',
                                    style: TextStyle(color: AppColors.grey300, fontSize: 12),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(color: AppColors.green600, fontSize: 12),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: TextStyle(color: AppColors.grey300, fontSize: 12),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(color: AppColors.green600, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    AppPrimaryButton(
                      title: 'Sign Up',
                      isLoading: auth.signupLoading,
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        authController.signUp(agreedToTerms: _agreedToTerms);
                      },
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AppText.rg(
                            'Already have an account? ',
                            fontSize: 14,
                            color: AppColors.grey200,
                          ),
                          AppText.md('Login', fontSize: 14, color: AppColors.green600),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppText.md(title, fontSize: 13, color: AppColors.grey500),
    );
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.grey100, fontSize: 15.sp),
      prefixIcon: Icon(icon, size: 20.w, color: AppColors.grey200),
      filled: true,
      fillColor: AppColors.grey50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.grey100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.green500),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_constants.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static const int otpLength = 6;

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPhoneController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();
  final TextEditingController signupConfirmPasswordController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode otpFocusNode = FocusNode();

  bool loginLoading = false;
  bool signupLoading = false;
  bool forgotLoading = false;
  bool otpLoading = false;
  bool resetLoading = false;
  bool otpSubmitted = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  String maskedEmail = 'john@comp***.com';

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    if (!AppConstants.emailValidator.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? loginPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter new password';
    if (value.length < 8) return 'At least 8 characters required';
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != newPasswordController.text) return 'Passwords do not match';
    return null;
  }

  bool get hasMinLength => newPasswordController.text.length >= 8;
  bool get hasUpperCase => RegExp(r'[A-Z]').hasMatch(newPasswordController.text);
  bool get hasLowerCase => RegExp(r'[a-z]').hasMatch(newPasswordController.text);
  bool get hasNumber => RegExp(r'\d').hasMatch(newPasswordController.text);
  bool get hasSpecial => RegExp(r'[@$!%*?&]').hasMatch(newPasswordController.text);

  int get strengthScore {
    int score = 0;
    if (hasMinLength) score++;
    if (hasUpperCase) score++;
    if (hasLowerCase) score++;
    if (hasNumber) score++;
    if (hasSpecial) score++;
    return score;
  }

  String get strengthText {
    if (strengthScore <= 2) return 'Weak';
    if (strengthScore <= 4) return 'Medium';
    return 'Strong';
  }

  void onResetPasswordChanged(String _) => update();

  void toggleNewPasswordVisibility() {
    obscureNewPassword = !obscureNewPassword;
    update();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    update();
  }

  Future<void> login() async {
    loginLoading = true;
    // update();
    // await Future<void>.delayed(const Duration(seconds: 2));
    // loginLoading = false;
    // update();
    Get.offAllNamed(AppRoutes.homeScreen);
  }

  String? fullNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter full name';
    if (value.trim().length < 3) return 'Name is too short';
    return null;
  }

  String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter phone number';
    final String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) return 'Please enter a valid phone number';
    return null;
  }

  String? signupConfirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != signupPasswordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> signUp({required bool agreedToTerms}) async {
    if (!agreedToTerms) {
      Get.snackbar('Terms Required', 'Please accept terms and privacy policy');
      return;
    }
    signupLoading = true;
    update();
    await Future<void>.delayed(const Duration(seconds: 2));
    signupLoading = false;
    maskedEmail = _maskEmail(signupEmailController.text.trim());
    update();
    Get.toNamed(
      AppRoutes.otpVerificationScreen,
      arguments: <String, String>{'maskedEmail': maskedEmail},
    );
  }

  Future<void> sendOtp() async {
    forgotLoading = true;
    update();
    await Future<void>.delayed(const Duration(seconds: 2));
    forgotLoading = false;
    maskedEmail = _maskEmail(forgotEmailController.text.trim());
    update();
    Get.toNamed(
      AppRoutes.otpVerificationScreen,
      arguments: <String, String>{'maskedEmail': maskedEmail},
    );
  }

  Future<void> tryReadClipboardOtp() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String text = (data?.text ?? '').trim();
    if (RegExp(r'^\d{6}$').hasMatch(text)) {
      otpController.text = text;
      await onOtpChanged(text);
    }
  }

  Future<void> onOtpChanged(String value) async {
    final String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly != value) {
      otpController.value = TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    }

    if (digitsOnly.length == otpLength && !otpSubmitted) {
      await verifyOtp(autoTriggered: true);
    } else if (digitsOnly.length < otpLength && otpSubmitted) {
      otpSubmitted = false;
      update();
    } else {
      update();
    }
  }

  Future<void> verifyOtp({bool autoTriggered = false}) async {
    if (otpLoading || otpSubmitted) return;
    if (otpController.text.length != otpLength) return;

    otpSubmitted = true;
    otpLoading = true;
    update();
    await Future<void>.delayed(const Duration(seconds: 2));
    otpLoading = false;
    update();
    Get.toNamed(AppRoutes.resetPasswordScreen);
    if (!autoTriggered) return;
  }

  Future<void> resetPassword() async {
    resetLoading = true;
    update();
    await Future<void>.delayed(const Duration(seconds: 2));
    resetLoading = false;
    update();
    Get.offNamed(AppRoutes.passwordUpdatedScreen);
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final List<String> parts = email.split('@');
    if (parts.length != 2) return email;
    final String local = parts.first;
    final String domain = parts.last;
    if (local.length <= 2) return '$local@$domain';
    return '${local.substring(0, 2)}***@$domain';
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPhoneController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    forgotEmailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }
}

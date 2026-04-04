import 'package:flutter/material.dart';
import 'package:flutter_extension/data/model/user_profile_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/views/screen/profile/policy_and_about.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  UserProfileModel profile = const UserProfileModel(
    displayName: 'John Smith',
    jobTitle: 'Sales Representative',
    employeeId: 'EMP-2451',
    email: 'rajesh.kumar@company.com',
    phone: '+91 98765 43210',
    company: 'AquaTech Solutions Pvt. Ltd.',
    isActive: true,
  );

  bool pushNotificationsEnabled = true;

  void setPushNotifications(bool value) {
    pushNotificationsEnabled = value;
    update();
  }

  void onEditProfile() {
    Get.toNamed(AppRoutes.editProfileScreen);
  }

  void onChangePassword() {
    Get.toNamed(AppRoutes.changePasswordScreen);
  }

  void onTermsAndPolicies() {
    Get.to(() => const TermsPoliciesScreen(title: 'Terms & Policies'));
  }

  void onAboutUs() {
    Get.to(() => const TermsPoliciesScreen(title: 'About Us'));
  }

  void updateProfileName(String fullName) {
    profile = profile.copyWith(displayName: fullName.trim());
    update();
    Get.back();
    Get.snackbar('Profile', 'Profile updated successfully.', snackPosition: SnackPosition.BOTTOM);
  }

  void updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    // Demo-level validation: replace with backend/API later.
    if (oldPassword.trim().isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      Get.snackbar('Password', 'Please fill all fields.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar('Password', 'New and confirm passwords do not match.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back();
    Get.snackbar('Password', 'Password updated successfully.', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> onDeleteAccount() async {
    final bool? ok = await _showFullWidthBottomConfirm(
      'Are sure want to delete account?',
    );

    if (ok == true) {
      Get.snackbar('Account', 'Request submitted (demo).');
    }
  }

  Future<void> onLogOut() async {
    final bool? ok = await _showFullWidthBottomConfirm(
      'Are sure want to log out?',
    );

    if (ok == true) {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  /// Edge-to-edge horizontally (no left/right [Dialog] or [SafeArea] inset).
  Future<bool?> _showFullWidthBottomConfirm(String message) {
    return Get.dialog<bool>(
      Dialog(
        alignment: Alignment.bottomCenter,
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        child: Builder(
          builder: (BuildContext context) {
            return SafeArea(
              top: false,
              left: false,
              right: false,
              minimum: EdgeInsets.zero,
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: _ConfirmYesNoDialog(
                  message: message,
                  yesText: 'Yes',
                  noText: 'No',
                  onYes: () => Get.back(result: true),
                  onNo: () => Get.back(result: false),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConfirmYesNoDialog extends StatelessWidget {
  const _ConfirmYesNoDialog({
    required this.message,
    required this.yesText,
    required this.noText,
    required this.onYes,
    required this.onNo,
  });

  final String message;
  final String yesText;
  final String noText;
  final VoidCallback onYes;
  final VoidCallback onNo;

  static const Color _panelBg = Color(0xFFF0FFF0);
  static const TextStyle _messageStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.grey500,
  );

  static const BorderRadius _sheetRadius = BorderRadius.vertical(
    top: Radius.circular(16),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: _sheetRadius,
        border: Border.all(color: AppColors.green500, width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: _messageStyle,
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: _DialogPillButton(
                  onPressed: onYes,
                  filled: false,
                  label: yesText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 9,
                child: _DialogPillButton(
                  onPressed: onNo,
                  filled: true,
                  label: noText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogPillButton extends StatelessWidget {
  const _DialogPillButton({
    required this.onPressed,
    required this.filled,
    required this.label,
  });

  final VoidCallback onPressed;
  final bool filled;
  final String label;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);

    if (filled) {
      return Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.green500.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: AppColors.green500,
            borderRadius: radius,
            child: InkWell(
              onTap: onPressed,
              borderRadius: radius,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: AppColors.white,
          borderRadius: radius,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: AppColors.grey100, width: 1.2),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.grey500,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

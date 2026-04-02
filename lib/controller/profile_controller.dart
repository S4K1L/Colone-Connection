import 'package:flutter/material.dart';
import 'package:flutter_extension/data/model/user_profile_model.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/helper/route_helper.dart';
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
    Get.toNamed(AppRoutes.termsPoliciesScreen);
  }

  void onAboutUs() {
    Get.toNamed(AppRoutes.aboutUsScreen);
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
    final bool? ok = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _ConfirmYesNoDialog(
          title: 'Are sure want to delete account?',
          yesText: 'Yes',
          noText: 'No',
          onYes: () => Get.back(result: true),
          onNo: () => Get.back(result: false),
        ),
      ),
    );

    if (ok == true) {
      Get.snackbar('Account', 'Request submitted (demo).');
    }
  }

  Future<void> onLogOut() async {
    final bool? ok = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: _ConfirmYesNoDialog(
          title: 'Are sure want to log out?',
          yesText: 'Yes',
          noText: 'No',
          onYes: () => Get.back(result: true),
          onNo: () => Get.back(result: false),
        ),
      ),
    );

    if (ok == true) {
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}

class _ConfirmYesNoDialog extends StatelessWidget {
  const _ConfirmYesNoDialog({
    required this.title,
    required this.yesText,
    required this.noText,
    required this.onYes,
    required this.onNo,
  });

  final String title;
  final String yesText;
  final String noText;
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green100),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onYes,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.green200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    yesText,
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    noText,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

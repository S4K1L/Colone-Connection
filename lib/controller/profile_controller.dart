import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_extension/model/multi_body.dart';
import 'package:flutter_extension/model/content_item_model.dart';
import 'package:flutter_extension/model/user_model.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/services/shared_prefs_service.dart';
import 'package:flutter_extension/util/api_constant.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/util/app_constants.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
import 'package:flutter_extension/views/screen/profile/content_screen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final ApiService apiService = ApiService();
  List<ContentItemModel> termsAndPolicies = <ContentItemModel>[];
  List<ContentItemModel> aboutUs = <ContentItemModel>[];
  bool isLoading = false;
  bool isContentLoading = false;
  bool isUpdatingProfile = false;
  File? selectedProfileImage;
  final ImagePicker _imagePicker = ImagePicker();
  UserModel profile = UserModel.empty();

  bool pushNotificationsEnabled = true;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  Future<void> getProfile() async {
    isLoading = true;
    update();
    try {
      final response = await apiService.get(
        ApiConstant.GET_USER_PROFILE,
        authReq: true,
      );
      final dynamic raw = response.data;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        profile = UserModel.fromJson(raw['data'] as Map<String, dynamic>);
      } else {
        profile = UserModel.empty();
      }
    } catch (e) {
      showCustomSnackBar(
        'Something went wrong. Please try again.',
        getXSnackBar: true,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getTermsAndPolicies(String endPoint) async {
    isContentLoading = true;
    update();
    try {
      final response = await apiService.get(endPoint);
      final dynamic raw = response.data;

      List<dynamic> dataList = <dynamic>[];
      if (raw is Map<String, dynamic>) {
        if (raw['data'] is List) {
          dataList = raw['data'] as List<dynamic>;
        } else if (raw['data'] is Map<String, dynamic>) {
          dataList = <dynamic>[raw['data']];
        }
      } else if (raw is List) {
        dataList = raw;
      }

      final List<ContentItemModel> items = dataList
          .whereType<Map<String, dynamic>>()
          .map(ContentItemModel.fromJson)
          .toList();

      if (endPoint == ApiConstant.GET_TERMS_AND_POLICIES) {
        termsAndPolicies = items;
      } else if (endPoint == ApiConstant.GET_ABOUT_US) {
        aboutUs = items;
      }
    } catch (e) {
      debugPrint('Error fetching content: $e');
    } finally {
      isContentLoading = false;
      update();
    }
  }

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
    Get.to(
      () => const ContentScreen(
        title: 'Terms & Policies',
        endPoint: ApiConstant.GET_TERMS_AND_POLICIES,
      ),
    );
  }

  void onAboutUs() {
    Get.to(
      () => const ContentScreen(
        title: 'About Us',
        endPoint: ApiConstant.GET_ABOUT_US,
      ),
    );
  }

  Future<void> updateProfileName(String fullName) async {
    final String trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      showCustomSnackBar('Full name cannot be empty.', getXSnackBar: true);
      return;
    }
    if (isUpdatingProfile) return;

    isUpdatingProfile = true;
    update();
    try {
      final dio.Response<dynamic> response;
      if (selectedProfileImage != null) {
        response = await apiService.patchMultipartData(
          ApiConstant.UPDATE_USER_PROFILE,
          <String, dynamic>{'full_name': trimmedName},
          multipartBody: <MultipartBody>[
            MultipartBody(key: 'image', file: selectedProfileImage!),
          ],
          authReq: true,
        );
      } else {
        response = await apiService.patch(
          ApiConstant.UPDATE_USER_PROFILE,
          <String, dynamic>{'full_name': trimmedName},
          authReq: true,
        );
      }
      final dynamic raw = response.data;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        profile = UserModel.fromJson(raw['data'] as Map<String, dynamic>);
      } else {
        profile = profile.copyWith(fullName: trimmedName);
      }
      selectedProfileImage = null;
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        showCustomSnackBar(
          'Profile updated successfully.',
          getXSnackBar: true,
          isError: false,
        );
      });
      Get.back();
    } catch (e) {
      showCustomSnackBar(
        'Something went wrong. Please try again.',
        getXSnackBar: true,
      );
    } finally {
      isUpdatingProfile = false;
      update();
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      selectedProfileImage = File(picked.path);
      update();
    } catch (_) {
      showCustomSnackBar(
        'Could not pick image. Please try again.',
        getXSnackBar: true,
      );
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading = true;
    update();
    try {
      if (oldPassword.trim().isEmpty ||
          newPassword.trim().isEmpty ||
          confirmPassword.trim().isEmpty) {
        showCustomSnackBar('Please fill all fields.', getXSnackBar: true);
        return;
      }
      if (newPassword != confirmPassword) {
        showCustomSnackBar(
          'New and confirm passwords do not match.',
          getXSnackBar: true,
        );
        return;
      }
      await apiService.post(ApiConstant.CHANGE_PASSWORD, {
        'old_password': oldPassword,
        'new_password': newPassword,
      }, authReq: true);
    } catch (e) {
      showCustomSnackBar(
        "Something went wrong. Please try again.",
        getXSnackBar: true,
      );
    } finally {
      isLoading = false;
      update();
      Get.back();
      showCustomSnackBar(
        'Password updated successfully.',
        getXSnackBar: true,
        isError: false,
      );
    }
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
      await SharedPrefsService.remove(AppConstants.TOKEN);

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
          Text(message, textAlign: TextAlign.center, style: _messageStyle),
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

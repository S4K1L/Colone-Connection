import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_extension/services/api_service.dart';
import 'package:flutter_extension/views/base/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddCustomerController extends GetxController {
  final ApiService apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController ownerNameCtrl = TextEditingController();
  final TextEditingController companyNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController alternatePhoneCtrl = TextEditingController();

  File? imageFile;
  double latitude = 23.8103;
  double longitude = 90.4125;
  String locationUrl = "https://maps.google.com/?q=23.8103,90.4125";

  bool isLoading = false;

  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile = File(picked.path);
      update();
    }
  }

  Future<void> saveCustomer(String colonyId) async {
    if (ownerNameCtrl.text.trim().isEmpty || 
        companyNameCtrl.text.trim().isEmpty || 
        phoneCtrl.text.trim().isEmpty) {
      showCustomSnackBar("Please fill owner name, company, and phone", isError: true);
      return;
    }

    isLoading = true;
    update();

    try {
      final Map<String, dynamic> data = {
        'owner_name': ownerNameCtrl.text.trim(),
        'company_name': companyNameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'location_url': locationUrl,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (imageFile != null) {
        data['image'] = imageFile;
      }

      final response = await apiService.post(
        "/sales_team/add-customer/$colonyId/",
        data,
        isMultiPart: true,
        authReq: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Customer added successfully", isError: false);
        // Navigate back and signal refresh
        Get.back(result: true);
      }
    } catch (e) {
      // Error is handled by ApiService interceptor (snackbar shown)
      debugPrint("AddCustomer Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    ownerNameCtrl.dispose();
    companyNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    alternatePhoneCtrl.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/screen/profile/widgets/profile_body.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (ProfileController c) {
        return Scaffold(
          backgroundColor: AppColors.green25,
          body: SafeArea(
            bottom: false,
            child: ProfileBody(controller: c),
          ),
        );
      },
    );
  }
}

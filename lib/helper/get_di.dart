
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter_extension/controller/auth_controller.dart';
import 'package:flutter_extension/controller/colonies_controller.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/controller/notifications_controller.dart';
import 'package:flutter_extension/controller/profile_controller.dart';
import 'package:flutter_extension/controller/splash_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/theme_controller.dart';


Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);

  // Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController());
  Get.lazyPut(() => AuthController(), fenix: true);
  Get.lazyPut(() => HomeController(), fenix: true);
  Get.lazyPut(() => ColoniesController(), fenix: true);
  Get.lazyPut(() => NotificationsController(), fenix: true);
  Get.lazyPut(() => ProfileController(), fenix: true);
}
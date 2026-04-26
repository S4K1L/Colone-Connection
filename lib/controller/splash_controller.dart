import 'package:flutter_extension/helper/route_helper.dart';
import 'package:flutter_extension/services/shared_prefs_service.dart';
import 'package:flutter_extension/util/app_constants.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {


  jumpNextScreen() {
    SharedPrefsService.get(AppConstants.TOKEN).then((value) {
      if (value != null && value.isNotEmpty && value != 'null') {
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        Get.offAllNamed(AppRoutes.loginScreen);
      }
    });
  }



}

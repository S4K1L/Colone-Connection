import 'package:flutter_extension/helper/route_helper.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {


  jumpNextScreen() {
    // TODO: Replace with actual session/token check.
    Get.offNamed(AppRoutes.loginScreen);
  }



}

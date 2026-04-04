import 'package:flutter_extension/helper/route_helper.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {


  jumpNextScreen() {
    Get.offNamed(AppRoutes.loginScreen);
  }



}

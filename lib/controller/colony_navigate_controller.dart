import 'package:flutter_extension/helper/colony_flow_args.dart';
import 'package:get/get.dart';

class ColonyNavigateController extends GetxController {
  ColonyNavigateController({required this.args});

  final ColonyNavigateArgs args;

  /// 0 Contact, 1 Notes, 2 Machinery (map), 3 Visit History
  int tabIndex = 2;

  void setTab(int index) {
    tabIndex = index;
    update();
  }

  void onArrived() {
    Get.snackbar('Colony', 'Marked as arrived (demo).');
  }
}

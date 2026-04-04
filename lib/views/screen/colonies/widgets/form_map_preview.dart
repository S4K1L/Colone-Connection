import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/home_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map block for add-colony / add-customer flows. Falls back if no API key.
class FormMapPreview extends StatelessWidget {
  const FormMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.find<HomeController>();

    if (!home.hasMapsKey) {
      return Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.grey100),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.map_outlined, size: 40.sp, color: AppColors.grey300),
            SizedBox(height: 8.h),
            AppText.rg(
              'Map preview',
              fontSize: 13,
              color: AppColors.grey300,
              useResponsiveSize: true,
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: SizedBox(
        height: 180.h,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: HomeController.center,
                zoom: 14,
              ),
              markers: <Marker>{
                const Marker(
                  markerId: MarkerId('form_pin'),
                  position: HomeController.center,
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: false,
            ),
            Positioned(
              right: 10.w,
              bottom: 10.h,
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
                elevation: 2,
                child: InkWell(
                  onTap: () => Get.snackbar('Location', 'Using current (demo).'),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.navigation_rounded,
                          size: 18.sp,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 6.w),
                        AppText.smd(
                          'Use Current',
                          fontSize: 12,
                          color: AppColors.grey500,
                          useResponsiveSize: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

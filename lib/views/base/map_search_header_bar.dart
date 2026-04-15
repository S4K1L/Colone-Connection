import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Green header with circular back control and bordered search field + trailing search icon.
class MapSearchHeaderBar extends StatelessWidget {
  const MapSearchHeaderBar({
    super.key,
    required this.controller,
    required this.onBack,
    this.hintText = 'Search colony or customers...',
  });

  final TextEditingController controller;
  final VoidCallback onBack;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: onBack,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF408E1A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 18.w,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.white, width: 1),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14.sp,
                    ),
                    cursorColor: AppColors.white,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: AppColors.white80,
                        fontSize: 13.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: AppColors.white,
                  size: 22.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

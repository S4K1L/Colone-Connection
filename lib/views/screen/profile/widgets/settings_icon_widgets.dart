import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_svg_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsIconBox extends StatelessWidget {
  const SettingsIconBox({
    super.key,
    required this.svgPath,
    this.iconColor,
    this.background = false,
  });

  final String svgPath;
  final Color? iconColor;
  final bool background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: background ? AppColors.grey50 : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        svgPath,
        size: background ? 22.w : 40.w,
        color: iconColor ?? AppColors.grey400,
      ),
    );
  }
}

class SettingsPngIconBox extends StatelessWidget {
  const SettingsPngIconBox({
    super.key,
    required this.asset,
    this.background = false,
  });

  final String asset;
  final bool background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: background ? AppColors.grey50 : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        width: 40.w,
        height: 40.w,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.apartment_rounded,
            size: 22.w,
            color: AppColors.grey400,
          );
        },
      ),
    );
  }
}

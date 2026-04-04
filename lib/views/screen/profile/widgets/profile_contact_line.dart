import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_svg_icon.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileContactLine extends StatelessWidget {
  const ProfileContactLine({
    super.key,
    required this.svgPath,
    required this.text,
  });

  final String svgPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSvgIcon(
          svgPath,
          size: 20.w,
          color: AppColors.grey300,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AppText.rg(
            text,
            fontSize: 13,
            color: AppColors.grey400,
            useResponsiveSize: true,
          ),
        ),
      ],
    );
  }
}

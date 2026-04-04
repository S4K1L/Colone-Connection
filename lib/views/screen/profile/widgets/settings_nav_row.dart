import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/profile/widgets/settings_icon_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    this.svgPath,
    this.leadingIcon,
    required this.label,
    required this.onTap,
    this.background = true,
    this.danger = false,
  });

  final String? svgPath;
  final Widget? leadingIcon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool background;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        danger ? AppColors.errorColor : AppColors.grey500;
    final Color iconColor =
        danger ? AppColors.errorColor : AppColors.grey400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Row(
            children: <Widget>[
              leadingIcon ??
                  SettingsIconBox(
                    svgPath: svgPath!,
                    iconColor: iconColor,
                    background: background,
                  ),
              SizedBox(width: 14.w),
              Expanded(
                child: AppText.smd(
                  label,
                  fontSize: 15,
                  color: textColor,
                  useResponsiveSize: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

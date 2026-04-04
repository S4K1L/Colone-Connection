import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_extension/views/screen/profile/widgets/settings_icon_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    super.key,
    required this.svgPath,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String svgPath;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          child: Row(
            children: <Widget>[
              SettingsIconBox(svgPath: svgPath, background: true),
              SizedBox(width: 14.w),
              Expanded(
                child: AppText.smd(
                  label,
                  fontSize: 15,
                  color: AppColors.grey500,
                  useResponsiveSize: true,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: AppColors.green500,
                  activeThumbColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Green gradient header: circular back, title, subtitle, optional circular action.
class ColonyFlowHeader extends StatelessWidget {
  const ColonyFlowHeader({
    super.key,
    required this.onBack,
    required this.title,
    this.subtitle,
    this.onTrailingTap,
    this.trailingIcon,
  });

  final VoidCallback onBack;
  final String title;
  final String? subtitle;
  final VoidCallback? onTrailingTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 16.w, 20.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF2EAD4B),
            Color(0xFF4BC76A),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CircleIconButton(
            icon: Icons.arrow_back,
            onTap: onBack,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText.smd(
                  title,
                  fontSize: 20,
                  color: AppColors.white,
                  useResponsiveSize: true,
                ),
                if (subtitle != null) ...<Widget>[
                  SizedBox(height: 4.h),
                  AppText.rg(
                    subtitle!,
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.92),
                    useResponsiveSize: true,
                  ),
                ],
              ],
            ),
          ),
          if (onTrailingTap != null && trailingIcon != null) ...<Widget>[
            SizedBox(width: 8.w),
            _CircleIconButton(
              icon: trailingIcon!,
              onTap: onTrailingTap!,
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

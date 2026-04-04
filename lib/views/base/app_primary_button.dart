import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    this.width,
    this.borderRadius,
    this.gradient,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final bool canTap = !isLoading && onPressed != null;

    return Opacity(
      opacity: canTap ? 1 : 0.9,
      child: InkWell(
        onTap: canTap ? onPressed : null,
        borderRadius: BorderRadius.circular((borderRadius ?? 14).r),
        child: Container(
          width: width ?? double.infinity,
          height: (height ?? 48).h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((borderRadius ?? 14).r),
            gradient:
                gradient ??
                const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
                ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.green300.withValues(alpha: 0.35),
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.1,
                      color: AppColors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppText.md(
                        title,
                        fontSize: 17,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 8.w),
                      const Icon(Icons.arrow_forward, size: 18, color: AppColors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

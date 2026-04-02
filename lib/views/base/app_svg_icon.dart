import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an SVG from [assetPath] with optional [color] tint (full icon).
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.assetPath, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final double w = width ?? size ?? 24.w;
    final double h = height ?? size ?? 24.w;
    return SvgPicture.asset(
      assetPath,
      width: w,
      height: h,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.color,
    this.height,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.style,
    this.useResponsiveSize = true,
  });

  const AppText.rg(
    this.text, {
    super.key,
    this.fontSize = 14,
    FontWeight? fontWeight,
    this.color,
    this.height,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.style,
    this.useResponsiveSize = true,
  }) : fontWeight = fontWeight ?? FontWeight.w400;

  const AppText.md(
    this.text, {
    super.key,
    this.fontSize = 14,
    FontWeight? fontWeight,
    this.color,
    this.height,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.style,
    this.useResponsiveSize = true,
  }) : fontWeight = fontWeight ?? FontWeight.w500;

  const AppText.smd(
    this.text, {
    super.key,
    this.fontSize = 14,
    FontWeight? fontWeight,
    this.color,
    this.height,
    this.letterSpacing,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.style,
    this.useResponsiveSize = true,
  }) : fontWeight = fontWeight ?? FontWeight.w600;

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final double? height;
  final double? letterSpacing;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextStyle? style;
  final bool useResponsiveSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = TextStyle(
      fontSize: useResponsiveSize ? fontSize.sp : fontSize,
      fontWeight: fontWeight,
      color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
      height: height,
      letterSpacing: letterSpacing,
    );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: style == null ? baseStyle : baseStyle.merge(style),
    );
  }
}

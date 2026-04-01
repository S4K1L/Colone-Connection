import 'package:flutter/material.dart';

class AppColors {
  // Green palette
  static const Color green25 = Color(0xFFFDFFFD);
  static const Color green50 = Color(0xFFF0F8EC);
  static const Color green100 = Color(0xFFCFE9C5);
  static const Color green200 = Color(0xFFB8DEA9);
  static const Color green300 = Color(0xFF98CF82);
  static const Color green400 = Color(0xFF84C56A);
  static const Color green500 = Color(0xFF65B745);
  static const Color green600 = Color(0xFF5CA73F);
  static const Color green700 = Color(0xFF488231);
  static const Color green800 = Color(0xFF386526);
  static const Color green900 = Color(0xFF2A4D1D);

  // Grey palette
  static const Color grey50 = Color(0xFFE9E9E9);
  static const Color grey100 = Color(0xFFBBBBBB);
  static const Color grey200 = Color(0xFF9B9B9B);
  static const Color grey300 = Color(0xFF6D6D6D);
  static const Color grey400 = Color(0xFF515151);
  static const Color grey500 = Color(0xFF252525);
  static const Color grey600 = Color(0xFF222222);
  static const Color grey700 = Color(0xFF1A1A1A);
  static const Color grey800 = Color(0xFF141414);
  static const Color grey900 = Color(0xFF101010);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white90 = Color(0xFFF2F2F2);
  static const Color white80 = Color(0xFFEDEDED);
  static const Color white70 = Color(0xFFF0F0F0);
  static const Color whiteGlow45 = Color(0x73FFFFFF);
  static const Color errorColor = Color(0xFFE35D5D);

  static const MaterialColor greenSwatch = MaterialColor(
    0xFF65B745,
    <int, Color>{
      50: green50,
      100: green100,
      200: green200,
      300: green300,
      400: green400,
      500: green500,
      600: green600,
      700: green700,
      800: green800,
      900: green900,
    },
  );

  static Color primaryColor = green500;
  static Color backgroundColor = grey900;
  static Color cardColor = grey500;
  static Color cardLightColor = grey300;
  static Color borderColor = green500;
  static Color textColor = white;
  static Color subTextColor = grey50;
  static Color hintColor = grey100;
  static Color greyColor = grey100;
  static Color fillColor = grey50.withOpacity(0.3);
  static Color dividerColor = grey300;
  static Color shadowColor = const Color(0xFF2B2A2A);
  static Color bottomBarColor = grey600;

  static BoxShadow shadow = BoxShadow(
    blurRadius: 4,
    spreadRadius: 0,
    color: shadowColor,
    offset: const Offset(0, 2),
  );
}
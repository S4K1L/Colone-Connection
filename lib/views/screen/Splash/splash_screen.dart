import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/splash_controller.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/base/app_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _loadingStep = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), _tickLoading);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.find<SplashController>().jumpNextScreen();
      }
    });
  }

  void _tickLoading() {
    if (!mounted) return;
    setState(() {
      _loadingStep = (_loadingStep + 1) % 4;
    });
    Future.delayed(const Duration(milliseconds: 400), _tickLoading);
  }

  String get _dotLine {
    if (_loadingStep == 0) return '•';
    if (_loadingStep == 1) return '• •';
    if (_loadingStep == 2) return '• • •';
    return '• • •';
  }

  String get _loadingText {
    if (_loadingStep == 0) return 'Loading';
    if (_loadingStep == 1) return 'Loading.';
    if (_loadingStep == 2) return 'Loading..';
    return 'Loading...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFF408E1A), Color(0xFF17B85F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const Spacer(flex: 3),
              Container(
                width: 112.w,
                height: 112.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.16),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              SizedBox(height: 20.h),
              const AppText.smd(
                'Colony\nConnection',
                fontSize: 40,
                textAlign: TextAlign.center,
                height: 0.98,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                
              ),
              SizedBox(height: 4.h),
              const AppText.rg(
                'Sales Route Optimization',
                fontSize: 14,
                height: 1.0,
                color: AppColors.white70,
              ),
              const Spacer(flex: 4),
              AppText.md(
                _dotLine,
                fontSize: 30,
                useResponsiveSize: true,
                letterSpacing: 0.5,
                color: AppColors.white80,
              ),
              SizedBox(height: 10.h),
              AppText.rg(
                _loadingText,
                fontSize: 16,
                color: AppColors.white90,
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

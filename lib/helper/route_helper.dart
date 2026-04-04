import 'package:flutter_extension/views/base/custom_bottom_navbar.dart';
import 'package:flutter_extension/views/screen/route/plan_route_screen.dart';
import 'package:flutter_extension/views/screen/auth/forgot_password_screen.dart';
import 'package:flutter_extension/views/screen/auth/create_account_screen.dart';
import 'package:flutter_extension/views/screen/auth/login_screen.dart';
import 'package:flutter_extension/views/screen/auth/otp_verification_screen.dart';
import 'package:flutter_extension/views/screen/auth/password_updated_screen.dart';
import 'package:flutter_extension/views/screen/auth/reset_password_screen.dart';
import 'package:flutter_extension/views/screen/profile/change_password_screen.dart';
import 'package:flutter_extension/views/screen/profile/edit_profile_screen.dart';
import 'package:get/get.dart';
import '../views/screen/splash/splash_screen.dart';

class AppRoutes{

  static String splashScreen="/splash_screen";
  static String homeScreen="/home_screen";
  static String loginScreen="/login_screen";
  static String createAccountScreen="/create_account_screen";
  static String forgotPasswordScreen="/forgot_password_screen";
  static String otpVerificationScreen="/otp_verification_screen";
  static String resetPasswordScreen="/reset_password_screen";
  static String passwordUpdatedScreen="/password_updated_screen";
  static String planRouteScreen = '/plan_route';
  static String editProfileScreen = '/edit_profile';
  static String changePasswordScreen = '/change_password';

 static List<GetPage> page=[
    GetPage(name:splashScreen, page: ()=>const SplashScreen()),
     GetPage(name:homeScreen, page: ()=>const CustomBottomNavbar()),
     GetPage(name:loginScreen, page: ()=>const LoginScreen()),
     GetPage(name:createAccountScreen, page: ()=>const CreateAccountScreen()),
     GetPage(name:forgotPasswordScreen, page: ()=>const ForgotPasswordScreen()),
     GetPage(name:otpVerificationScreen, page: ()=>const OtpVerificationScreen()),
     GetPage(name:resetPasswordScreen, page: ()=>const ResetPasswordScreen()),
     GetPage(name:passwordUpdatedScreen, page: ()=>const PasswordUpdatedScreen()),
     GetPage(name: planRouteScreen, page: () => const PlanRouteScreen()),
     GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
     GetPage(name: changePasswordScreen, page: () => const ChangePasswordScreen()),
  ];



}
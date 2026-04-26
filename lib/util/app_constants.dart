// ignore_for_file: non_constant_identifier_names, constant_identifier_names

class AppConstants{

  static const String APP_NAME = 'Colony Connection';
  static const double APP_VERSION = 1.0;



  static const String TOKEN ="token";


  // share preference Key
  static String THEME ="theme";




  static RegExp emailValidator = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static RegExp passwordValidator = RegExp(
      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"
  );

}
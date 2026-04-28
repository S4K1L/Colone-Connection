// ignore_for_file: constant_identifier_names

class ApiConstant {
static const String BASE_URL = 'http://10.10.12.15:8080/api/v1';
static const String IMAGE_URL = 'http://10.10.12.15:8080';


static const String LOGIN_URL = '/auth/login';
static const String REFRESH_TOKEN = '/auth/refresh';
static const String FORGOT_PASSWORD = '/auth/forget-password';
static const String VERIFY_OTP = '/auth/otp-verify';
static const String RESET_PASSWORD = '/auth/reset-password';

//profile
static const String DELETE_ACCOUNT = '/user/delete-account';
static const String GET_USER_PROFILE = '/profiles/me/';
static const String UPDATE_USER_PROFILE = '/profiles/me/';
static const String CHANGE_PASSWORD = '/auth/change-password';


static const String GET_TERMS_AND_POLICIES = '/admin_dashboard/terms-conditions/public/';
static const String GET_ABOUT_US = '/about-us';

static const String GET_NOTIFICATIONS = '/notifications/';
}
class AppConstants {
  const AppConstants._();

  static const String appName = 'Meal Mate Delivery';
  static const String appNameAr = 'ميل ميت دليفري';
  static const String appVersion = '1.0.0';

  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;
  static const int maxRetries = 3;

  static const int defaultPageSize = 20;
  static const int firstPage = 1;

  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int otpLength = 6;
}

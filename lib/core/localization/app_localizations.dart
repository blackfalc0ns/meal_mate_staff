import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('ar'), Locale('en')];

  bool get isRtl => locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _values = {
    'ar': {
      'appTitle': 'MealMate Delivery',
      'splashHeadline': 'رفيقك في كل توصيل',
      'splashSubtitle': 'نقدم الأفضل، معا كل يوم',
      'loading': 'جاري التحميل...',
      'driverAppName': 'Stuff App',
      'welcomeBack': 'مرحبا بعودتك!',
      'loginSubtitle': 'سجل دخولك للمتابعة والاستلام',
      'phoneLabel': 'رقم الجوال',
      'phoneHint': 'أدخل رقم الجوال',
      'passwordLabel': 'كلمة المرور',
      'passwordHint': 'أدخل كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'login': 'تسجيل الدخول',
      'or': 'أو',
      'loginWithOtp': 'تسجيل الدخول برمز التحقق',
      'needHelp': 'تحتاج مساعدة؟',
      'getHelp': 'الحصول على مساعدة',
      'helpSubtitle': 'فريق الدعم معك لمساعدتك على مدار الساعة',
      'verifyPhoneTitle': 'تحقق من رقم هاتفك',
      'verifyPhoneSubtitle': 'لقد أرسلنا كود التحقق إلى رقم هاتفك',
      'verifyEmailTitle': 'تحقق من البريد الإلكتروني',
      'verifyEmailSubtitle': 'لقد أرسلنا كود التحقق إلى بريدك الإلكتروني',
      'otpHint': 'أدخل الكود المكون من 6 أرقام',
      'verifyCode': 'تحقق من الكود',
      'resendIn': 'إعادة إرسال الكود خلال',
      'otpTimer': '00:45',
    },
    'en': {
      'appTitle': 'MealMate Delivery',
      'splashHeadline': 'Your delivery companion',
      'splashSubtitle': 'Delivering better, together every day',
      'loading': 'Loading...',
      'driverAppName': 'Stuff App',
      'welcomeBack': 'Welcome back!',
      'loginSubtitle': 'Sign in to continue and receive orders',
      'phoneLabel': 'Mobile number',
      'phoneHint': 'Enter mobile number',
      'passwordLabel': 'Password',
      'passwordHint': 'Enter password',
      'forgotPassword': 'Forgot password?',
      'login': 'Sign in',
      'or': 'or',
      'loginWithOtp': 'Sign in with verification code',
      'needHelp': 'Need help?',
      'getHelp': 'Get help',
      'helpSubtitle': 'Support is available around the clock',
      'verifyPhoneTitle': 'Verify your phone number',
      'verifyPhoneSubtitle': 'We sent a verification code to your phone',
      'verifyEmailTitle': 'Verify email address',
      'verifyEmailSubtitle': 'We sent a verification code to your email',
      'otpHint': 'Enter the 6-digit code',
      'verifyCode': 'Verify code',
      'resendIn': 'Resend code in',
      'otpTimer': '00:45',
    },
  };

  String _text(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key]!;

  String get appTitle => _text('appTitle');
  String get splashHeadline => _text('splashHeadline');
  String get splashSubtitle => _text('splashSubtitle');
  String get loading => _text('loading');
  String get driverAppName => _text('driverAppName');
  String get welcomeBack => _text('welcomeBack');
  String get loginSubtitle => _text('loginSubtitle');
  String get phoneLabel => _text('phoneLabel');
  String get phoneHint => _text('phoneHint');
  String get passwordLabel => _text('passwordLabel');
  String get passwordHint => _text('passwordHint');
  String get forgotPassword => _text('forgotPassword');
  String get login => _text('login');
  String get or => _text('or');
  String get loginWithOtp => _text('loginWithOtp');
  String get needHelp => _text('needHelp');
  String get getHelp => _text('getHelp');
  String get helpSubtitle => _text('helpSubtitle');
  String get verifyPhoneTitle => _text('verifyPhoneTitle');
  String get verifyPhoneSubtitle => _text('verifyPhoneSubtitle');
  String get verifyEmailTitle => _text('verifyEmailTitle');
  String get verifyEmailSubtitle => _text('verifyEmailSubtitle');
  String get otpHint => _text('otpHint');
  String get verifyCode => _text('verifyCode');
  String get resendIn => _text('resendIn');
  String get otpTimer => _text('otpTimer');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

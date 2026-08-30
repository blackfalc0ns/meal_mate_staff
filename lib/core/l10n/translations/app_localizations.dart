import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MealMate Delivery'**
  String get appTitle;

  /// No description provided for @splashHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your delivery companion'**
  String get splashHeadline;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivering better, together every day'**
  String get splashSubtitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @driverAppName.
  ///
  /// In en, this message translates to:
  /// **'Stuff App'**
  String get driverAppName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue and receive orders'**
  String get loginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get phoneHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @loginWithOtp.
  ///
  /// In en, this message translates to:
  /// **'Sign in with verification code'**
  String get loginWithOtp;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @getHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get getHelp;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support is available around the clock'**
  String get helpSubtitle;

  /// No description provided for @verifyPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verifyPhoneTitle;

  /// No description provided for @verifyPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your phone'**
  String get verifyPhoneSubtitle;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify email address'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to your email'**
  String get verifyEmailSubtitle;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpHint;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendIn;

  /// No description provided for @otpTimer.
  ///
  /// In en, this message translates to:
  /// **'00:45'**
  String get otpTimer;

  /// No description provided for @registrationPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get registrationPersonalData;

  /// No description provided for @registrationVehicleData.
  ///
  /// In en, this message translates to:
  /// **'Vehicle data'**
  String get registrationVehicleData;

  /// No description provided for @registrationDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get registrationDocuments;

  /// No description provided for @registrationReviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review order'**
  String get registrationReviewOrder;

  /// No description provided for @registrationChooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'Choose account type'**
  String get registrationChooseAccountType;

  /// No description provided for @registrationChooseRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the role you want to use'**
  String get registrationChooseRoleSubtitle;

  /// No description provided for @registrationDriverRole.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get registrationDriverRole;

  /// No description provided for @registrationDriverRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive orders and deliver them'**
  String get registrationDriverRoleSubtitle;

  /// No description provided for @registrationOpsRole.
  ///
  /// In en, this message translates to:
  /// **'Operations agent'**
  String get registrationOpsRole;

  /// No description provided for @registrationOpsRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage orders, drivers, and deliveries'**
  String get registrationOpsRoleSubtitle;

  /// No description provided for @registrationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get registrationConfirm;

  /// No description provided for @registrationDefaultRole.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get registrationDefaultRole;

  /// No description provided for @registrationReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your data before submitting'**
  String get registrationReviewSubtitle;

  /// No description provided for @registrationFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registrationFirstName;

  /// No description provided for @registrationFirstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get registrationFirstNameHint;

  /// No description provided for @registrationLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get registrationLastName;

  /// No description provided for @registrationLastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get registrationLastNameHint;

  /// No description provided for @registrationPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get registrationPhone;

  /// No description provided for @registrationPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get registrationPhoneHint;

  /// No description provided for @registrationEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registrationEmail;

  /// No description provided for @registrationEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get registrationEmailHint;

  /// No description provided for @registrationBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get registrationBirthDate;

  /// No description provided for @registrationBirthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Choose birth date'**
  String get registrationBirthDateHint;

  /// No description provided for @registrationNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get registrationNationality;

  /// No description provided for @registrationNationalityHint.
  ///
  /// In en, this message translates to:
  /// **'Choose nationality'**
  String get registrationNationalityHint;

  /// No description provided for @registrationCivilId.
  ///
  /// In en, this message translates to:
  /// **'Civil ID'**
  String get registrationCivilId;

  /// No description provided for @registrationCivilIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter civil ID'**
  String get registrationCivilIdHint;

  /// No description provided for @registrationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registrationContinue;

  /// No description provided for @registrationVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get registrationVehicleType;

  /// No description provided for @registrationVehicleTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose vehicle type'**
  String get registrationVehicleTypeHint;

  /// No description provided for @registrationVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Company / model'**
  String get registrationVehicleModel;

  /// No description provided for @registrationVehicleModelHint.
  ///
  /// In en, this message translates to:
  /// **'Choose company / model'**
  String get registrationVehicleModelHint;

  /// No description provided for @registrationManufactureYear.
  ///
  /// In en, this message translates to:
  /// **'Manufacture year'**
  String get registrationManufactureYear;

  /// No description provided for @registrationManufactureYearHint.
  ///
  /// In en, this message translates to:
  /// **'Choose manufacture year'**
  String get registrationManufactureYearHint;

  /// No description provided for @registrationPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get registrationPlateNumber;

  /// No description provided for @registrationPlateNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter plate number'**
  String get registrationPlateNumberHint;

  /// No description provided for @registrationKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get registrationKuwait;

  /// No description provided for @registrationVehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Vehicle color'**
  String get registrationVehicleColor;

  /// No description provided for @registrationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get registrationOther;

  /// No description provided for @registrationOwnVehicle.
  ///
  /// In en, this message translates to:
  /// **'Do you own the vehicle?'**
  String get registrationOwnVehicle;

  /// No description provided for @registrationYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get registrationYes;

  /// No description provided for @registrationNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get registrationNo;

  /// No description provided for @registrationCivilCard.
  ///
  /// In en, this message translates to:
  /// **'Civil card'**
  String get registrationCivilCard;

  /// No description provided for @registrationCivilCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear photo of a valid civil card'**
  String get registrationCivilCardSubtitle;

  /// No description provided for @registrationDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving license'**
  String get registrationDrivingLicense;

  /// No description provided for @registrationDrivingLicenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear photo of a valid driving license'**
  String get registrationDrivingLicenseSubtitle;

  /// No description provided for @registrationCarRegistration.
  ///
  /// In en, this message translates to:
  /// **'Car registration'**
  String get registrationCarRegistration;

  /// No description provided for @registrationCarRegistrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Front side of the car registration'**
  String get registrationCarRegistrationSubtitle;

  /// No description provided for @registrationVehiclePhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle photo'**
  String get registrationVehiclePhoto;

  /// No description provided for @registrationVehiclePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear exterior photo of the vehicle'**
  String get registrationVehiclePhotoSubtitle;

  /// No description provided for @registrationPersonalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Personal photo'**
  String get registrationPersonalPhoto;

  /// No description provided for @registrationPersonalPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal photo with clear background'**
  String get registrationPersonalPhotoSubtitle;

  /// No description provided for @registrationImportantNote.
  ///
  /// In en, this message translates to:
  /// **'Important note'**
  String get registrationImportantNote;

  /// No description provided for @registrationUploadNote.
  ///
  /// In en, this message translates to:
  /// **'Our team will review and verify your documents\nYou will be notified within 24-48 business hours.'**
  String get registrationUploadNote;

  /// No description provided for @registrationSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit acceptance request'**
  String get registrationSubmitRequest;

  /// No description provided for @registrationEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get registrationEdit;

  /// No description provided for @registrationUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get registrationUploaded;

  /// No description provided for @registrationReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Our team will review your request\nOnce accepted, your account will be activated and you will be notified.'**
  String get registrationReviewNote;

  /// No description provided for @registrationBackToEdit.
  ///
  /// In en, this message translates to:
  /// **'Back to edit'**
  String get registrationBackToEdit;

  /// No description provided for @registrationSampleFirstName.
  ///
  /// In en, this message translates to:
  /// **'Ahmad'**
  String get registrationSampleFirstName;

  /// No description provided for @registrationSampleLastName.
  ///
  /// In en, this message translates to:
  /// **'Al Sayed'**
  String get registrationSampleLastName;

  /// No description provided for @registrationSampleEmail.
  ///
  /// In en, this message translates to:
  /// **'ahmad.driver@mail.com'**
  String get registrationSampleEmail;

  /// No description provided for @registrationSamplePhone.
  ///
  /// In en, this message translates to:
  /// **'+962 7 9123 4567'**
  String get registrationSamplePhone;

  /// No description provided for @registrationSampleBirthDate.
  ///
  /// In en, this message translates to:
  /// **'1996/04/18'**
  String get registrationSampleBirthDate;

  /// No description provided for @registrationSampleNationality.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti'**
  String get registrationSampleNationality;

  /// No description provided for @registrationSampleCivilId.
  ///
  /// In en, this message translates to:
  /// **'287041812345'**
  String get registrationSampleCivilId;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

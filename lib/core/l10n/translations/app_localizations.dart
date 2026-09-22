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

  /// No description provided for @authRoleSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to continue'**
  String get authRoleSelectionTitle;

  /// No description provided for @authRoleSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select your job role to access your daily tasks'**
  String get authRoleSelectionSubtitle;

  /// No description provided for @rolesDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get rolesDriver;

  /// No description provided for @rolesDriverDesc.
  ///
  /// In en, this message translates to:
  /// **'Deliver orders, update statuses, and follow routes'**
  String get rolesDriverDesc;

  /// No description provided for @rolesDeliveryManager.
  ///
  /// In en, this message translates to:
  /// **'Delivery Manager'**
  String get rolesDeliveryManager;

  /// No description provided for @rolesDeliveryManagerDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage trips, assign drivers, and monitor dispatch'**
  String get rolesDeliveryManagerDesc;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

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

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

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

  /// No description provided for @registrationFullNameAr.
  ///
  /// In en, this message translates to:
  /// **'Full name in Arabic'**
  String get registrationFullNameAr;

  /// No description provided for @registrationFullNameArHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name in Arabic'**
  String get registrationFullNameArHint;

  /// No description provided for @registrationFullNameEn.
  ///
  /// In en, this message translates to:
  /// **'Full name in English'**
  String get registrationFullNameEn;

  /// No description provided for @registrationFullNameEnHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name in English'**
  String get registrationFullNameEnHint;

  /// No description provided for @registrationWorkplace.
  ///
  /// In en, this message translates to:
  /// **'Workplace & Restaurant'**
  String get registrationWorkplace;

  /// No description provided for @registrationIdentityAndContact.
  ///
  /// In en, this message translates to:
  /// **'Identity & Contact Details'**
  String get registrationIdentityAndContact;

  /// No description provided for @registrationRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Partner restaurant'**
  String get registrationRestaurant;

  /// No description provided for @registrationRestaurantHint.
  ///
  /// In en, this message translates to:
  /// **'Choose restaurant'**
  String get registrationRestaurantHint;

  /// No description provided for @registrationRestaurantHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose the partner restaurant you work for'**
  String get registrationRestaurantHelp;

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
  /// **'Enter email (optional)'**
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

  /// No description provided for @registrationIdExpiry.
  ///
  /// In en, this message translates to:
  /// **'ID expiry date'**
  String get registrationIdExpiry;

  /// No description provided for @registrationIdExpiryHint.
  ///
  /// In en, this message translates to:
  /// **'Choose ID expiry date'**
  String get registrationIdExpiryHint;

  /// No description provided for @registrationContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registrationContinue;

  /// No description provided for @registrationVehicleSpecifications.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Specifications'**
  String get registrationVehicleSpecifications;

  /// No description provided for @registrationLicensesAndPlate.
  ///
  /// In en, this message translates to:
  /// **'License & Plate Information'**
  String get registrationLicensesAndPlate;

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

  /// No description provided for @registrationCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get registrationCountry;

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

  /// No description provided for @registrationVehicleModelSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search vehicle models'**
  String get registrationVehicleModelSearchHint;

  /// No description provided for @registrationLicenseExpiry.
  ///
  /// In en, this message translates to:
  /// **'Driving license expiry'**
  String get registrationLicenseExpiry;

  /// No description provided for @registrationVehicleLicenseExpiry.
  ///
  /// In en, this message translates to:
  /// **'Vehicle license expiry'**
  String get registrationVehicleLicenseExpiry;

  /// No description provided for @registrationContractExpiry.
  ///
  /// In en, this message translates to:
  /// **'Contract expiry (optional)'**
  String get registrationContractExpiry;

  /// No description provided for @registrationClearContractExpiry.
  ///
  /// In en, this message translates to:
  /// **'Clear contract expiry'**
  String get registrationClearContractExpiry;

  /// No description provided for @registrationDateHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a future date'**
  String get registrationDateHint;

  /// No description provided for @registrationHexColor.
  ///
  /// In en, this message translates to:
  /// **'HEX color'**
  String get registrationHexColor;

  /// No description provided for @registrationUseColor.
  ///
  /// In en, this message translates to:
  /// **'Use color'**
  String get registrationUseColor;

  /// No description provided for @registrationInvalidHexColor.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit HEX color'**
  String get registrationInvalidHexColor;

  /// No description provided for @validationFutureDate.
  ///
  /// In en, this message translates to:
  /// **'Date must be in the future'**
  String get validationFutureDate;

  /// No description provided for @validationManufactureYearRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a year from 1990 through {maximumYear}'**
  String validationManufactureYearRange(int maximumYear);

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

  /// No description provided for @registrationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get registrationRequired;

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

  /// No description provided for @registrationUploadedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Uploaded documents'**
  String get registrationUploadedDocuments;

  /// No description provided for @registrationCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get registrationCamera;

  /// No description provided for @registrationGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get registrationGallery;

  /// No description provided for @registrationTapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload'**
  String get registrationTapToUpload;

  /// No description provided for @registrationUploadFormats.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG, PDF'**
  String get registrationUploadFormats;

  /// No description provided for @registrationCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get registrationCar;

  /// No description provided for @registrationPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get registrationPurple;

  /// No description provided for @accountStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get accountStatusTitle;

  /// No description provided for @accountStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are checking your data and documents'**
  String get accountStatusSubtitle;

  /// No description provided for @accountStatusAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account has been accepted!'**
  String get accountStatusAcceptedTitle;

  /// No description provided for @accountStatusAcceptedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account was activated successfully\nYou can start working now'**
  String get accountStatusAcceptedBody;

  /// No description provided for @accountStatusRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application rejected'**
  String get accountStatusRejectedTitle;

  /// No description provided for @accountStatusRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Sorry, your current request was not accepted\nPlease review the rejection reason below\nYou can edit the data and resubmit'**
  String get accountStatusRejectedBody;

  /// No description provided for @accountStatusMoreInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Data changes required'**
  String get accountStatusMoreInfoTitle;

  /// No description provided for @accountStatusMoreInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Please update the following data\nand resend the request'**
  String get accountStatusMoreInfoBody;

  /// No description provided for @accountStatusUnderReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is under review'**
  String get accountStatusUnderReviewTitle;

  /// No description provided for @accountStatusUnderReviewBody.
  ///
  /// In en, this message translates to:
  /// **'We are verifying your documents and information to make sure they meet\nwork requirements'**
  String get accountStatusUnderReviewBody;

  /// No description provided for @accountStatusNotifyWhenApproved.
  ///
  /// In en, this message translates to:
  /// **'We will notify you as soon as your account is approved and you can start receiving orders'**
  String get accountStatusNotifyWhenApproved;

  /// No description provided for @accountStatusNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get accountStatusNeedHelp;

  /// No description provided for @accountStatusHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support is available to answer your questions'**
  String get accountStatusHelpSubtitle;

  /// No description provided for @accountStatusGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get accountStatusGetHelp;

  /// No description provided for @accountStatusTrustNote.
  ///
  /// In en, this message translates to:
  /// **'We appreciate your patience, and promise you a successful and safe delivery experience\nwith MealMate'**
  String get accountStatusTrustNote;

  /// No description provided for @accountStatusStartWork.
  ///
  /// In en, this message translates to:
  /// **'Start work'**
  String get accountStatusStartWork;

  /// No description provided for @accountStatusBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get accountStatusBackToLogin;

  /// No description provided for @accountStatusResubmit.
  ///
  /// In en, this message translates to:
  /// **'Resubmit'**
  String get accountStatusResubmit;

  /// No description provided for @accountStatusEditAndResend.
  ///
  /// In en, this message translates to:
  /// **'Edit and resend'**
  String get accountStatusEditAndResend;

  /// No description provided for @accountStatusRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get accountStatusRejectionReason;

  /// No description provided for @accountStatusChangeReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for requested changes'**
  String get accountStatusChangeReason;

  /// No description provided for @accountStatusReasonCivilIdMismatch.
  ///
  /// In en, this message translates to:
  /// **'Civil ID does not match the submitted data'**
  String get accountStatusReasonCivilIdMismatch;

  /// No description provided for @accountStatusReasonDrivingLicenseExpired.
  ///
  /// In en, this message translates to:
  /// **'Driving license validity date has expired'**
  String get accountStatusReasonDrivingLicenseExpired;

  /// No description provided for @accountStatusReasonVehicleRegistrationUnclear.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration photo is unclear'**
  String get accountStatusReasonVehicleRegistrationUnclear;

  /// No description provided for @accountStatusReasonDrivingLicenseUnclear.
  ///
  /// In en, this message translates to:
  /// **'Driving license is unclear'**
  String get accountStatusReasonDrivingLicenseUnclear;

  /// No description provided for @accountStatusReasonVehicleRegistrationExpired.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration is expired'**
  String get accountStatusReasonVehicleRegistrationExpired;

  /// No description provided for @accountStatusPendingChip.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get accountStatusPendingChip;

  /// No description provided for @dispatcherRestaurantName.
  ///
  /// In en, this message translates to:
  /// **'MealMate Restaurant Kuwait'**
  String get dispatcherRestaurantName;

  /// No description provided for @dispatcherRoleBadge.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher'**
  String get dispatcherRoleBadge;

  /// No description provided for @dispatcherOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get dispatcherOrdersTitle;

  /// No description provided for @dispatcherOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Box queue awaiting assignment'**
  String get dispatcherOrdersSubtitle;

  /// No description provided for @dispatcherStatusPendingAssignment.
  ///
  /// In en, this message translates to:
  /// **'Pending Assignment'**
  String get dispatcherStatusPendingAssignment;

  /// No description provided for @dispatcherStatusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get dispatcherStatusAssigned;

  /// No description provided for @dispatcherStatusInDelivery.
  ///
  /// In en, this message translates to:
  /// **'In Delivery'**
  String get dispatcherStatusInDelivery;

  /// No description provided for @dispatcherStatusProblems.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get dispatcherStatusProblems;

  /// No description provided for @dispatcherFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dispatcherFilterAll;

  /// No description provided for @dispatcherPriorityNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get dispatcherPriorityNew;

  /// No description provided for @dispatcherPriorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get dispatcherPriorityUrgent;

  /// No description provided for @dispatcherPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get dispatcherPriorityHigh;

  /// No description provided for @dispatcherPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get dispatcherPriorityNormal;

  /// No description provided for @dispatcherMealsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Meals'**
  String dispatcherMealsCount(int count);

  /// No description provided for @dispatcherTodaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get dispatcherTodaysMeals;

  /// No description provided for @dispatcherDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get dispatcherDistance;

  /// No description provided for @dispatcherDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String dispatcherDistanceKm(String distance);

  /// No description provided for @dispatcherAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get dispatcherAssign;

  /// No description provided for @dispatcherDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get dispatcherDetails;

  /// No description provided for @dispatcherNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dispatcherNavHome;

  /// No description provided for @dispatcherNavOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get dispatcherNavOrders;

  /// No description provided for @dispatcherNavDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get dispatcherNavDelivery;

  /// No description provided for @dispatcherNavSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get dispatcherNavSupport;

  /// No description provided for @dispatcherNavAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get dispatcherNavAccount;

  /// No description provided for @dispatcherSuggestionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Suggested :'**
  String get dispatcherSuggestionPrefix;

  /// No description provided for @dispatcherLeastBusyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Least busy :'**
  String get dispatcherLeastBusyPrefix;

  /// No description provided for @dispatcherSuggestionNearest.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {name} (Nearest)'**
  String dispatcherSuggestionNearest(String name);

  /// No description provided for @dispatcherSuggestionLeastLoaded.
  ///
  /// In en, this message translates to:
  /// **'Least busy: {name}'**
  String dispatcherSuggestionLeastLoaded(String name);

  /// No description provided for @dispatcherNoOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get dispatcherNoOrdersTitle;

  /// No description provided for @dispatcherNoOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No boxes in the queue for this status'**
  String get dispatcherNoOrdersSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get navDelivery;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get navSupport;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @assignBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Box {boxCode}'**
  String assignBoxTitle(String boxCode);

  /// No description provided for @assignBoxWorkArea.
  ///
  /// In en, this message translates to:
  /// **'Customer Area'**
  String get assignBoxWorkArea;

  /// No description provided for @assignBoxDistanceRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Distance from Restaurant'**
  String get assignBoxDistanceRestaurant;

  /// No description provided for @assignBoxRequiredTime.
  ///
  /// In en, this message translates to:
  /// **'Required Time'**
  String get assignBoxRequiredTime;

  /// No description provided for @assignBoxPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get assignBoxPriority;

  /// No description provided for @assignBoxMealsCount.
  ///
  /// In en, this message translates to:
  /// **'Meals Count'**
  String get assignBoxMealsCount;

  /// No description provided for @assignBoxBestSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Best Suggestion'**
  String get assignBoxBestSuggestion;

  /// No description provided for @assignBoxCurrentLoad.
  ///
  /// In en, this message translates to:
  /// **'Current Load'**
  String get assignBoxCurrentLoad;

  /// No description provided for @assignBoxDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get assignBoxDistanceLabel;

  /// No description provided for @assignBoxExpectedCompletion.
  ///
  /// In en, this message translates to:
  /// **'Expected Completion'**
  String get assignBoxExpectedCompletion;

  /// No description provided for @assignBoxSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Select Driver to Assign'**
  String get assignBoxSelectDriver;

  /// No description provided for @assignBoxViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get assignBoxViewAll;

  /// No description provided for @assignBoxConfirmAssignment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Assignment'**
  String get assignBoxConfirmAssignment;

  /// No description provided for @assignBoxViewBox.
  ///
  /// In en, this message translates to:
  /// **'View Box'**
  String get assignBoxViewBox;

  /// No description provided for @driversTitle.
  ///
  /// In en, this message translates to:
  /// **'Drivers List'**
  String get driversTitle;

  /// No description provided for @driversSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the suitable driver for order dispatch'**
  String get driversSubtitle;

  /// No description provided for @driversByArea.
  ///
  /// In en, this message translates to:
  /// **'By Area'**
  String get driversByArea;

  /// No description provided for @driversAll.
  ///
  /// In en, this message translates to:
  /// **'All Drivers'**
  String get driversAll;

  /// No description provided for @driversTotalCount.
  ///
  /// In en, this message translates to:
  /// **'Total Drivers'**
  String get driversTotalCount;

  /// No description provided for @driversAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'Available Drivers'**
  String get driversAvailableCount;

  /// No description provided for @driversBusyCount.
  ///
  /// In en, this message translates to:
  /// **'Busy Now'**
  String get driversBusyCount;

  /// No description provided for @driversSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Drivers in {area} ({count})'**
  String driversSectionTitle(String area, int count);

  /// No description provided for @driversAllSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'All Drivers ({count})'**
  String driversAllSectionTitle(int count);

  /// No description provided for @driversSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get driversSort;

  /// No description provided for @driversStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get driversStatusAvailable;

  /// No description provided for @driversStatusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get driversStatusOnTheWay;

  /// No description provided for @driversStatusOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get driversStatusOnBreak;

  /// No description provided for @driversCurrentOrders.
  ///
  /// In en, this message translates to:
  /// **'Current Orders'**
  String get driversCurrentOrders;

  /// No description provided for @driversCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed Today'**
  String get driversCompletedToday;

  /// No description provided for @driversDistanceFromYou.
  ///
  /// In en, this message translates to:
  /// **'Distance from you'**
  String get driversDistanceFromYou;

  /// No description provided for @driversSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get driversSelect;

  /// No description provided for @driversUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get driversUnavailable;

  /// No description provided for @driversViewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View Drivers on Map'**
  String get driversViewOnMap;

  /// No description provided for @driversDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} Km'**
  String driversDistanceKm(String distance);

  /// No description provided for @areaSalmiya.
  ///
  /// In en, this message translates to:
  /// **'Salmiya'**
  String get areaSalmiya;

  /// No description provided for @areaHawally.
  ///
  /// In en, this message translates to:
  /// **'Hawally'**
  String get areaHawally;

  /// No description provided for @areaHateen.
  ///
  /// In en, this message translates to:
  /// **'Hateen'**
  String get areaHateen;

  /// No description provided for @areaFarwaniya.
  ///
  /// In en, this message translates to:
  /// **'Farwaniya'**
  String get areaFarwaniya;

  /// No description provided for @areaCapital.
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get areaCapital;

  /// No description provided for @mapDriverTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Tracking'**
  String get mapDriverTrackingTitle;

  /// No description provided for @mapDriverTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time driver monitoring'**
  String get mapDriverTrackingSubtitle;

  /// No description provided for @mapKpiActive.
  ///
  /// In en, this message translates to:
  /// **'Active Driver'**
  String get mapKpiActive;

  /// No description provided for @mapKpiInDelivery.
  ///
  /// In en, this message translates to:
  /// **'In Delivery'**
  String get mapKpiInDelivery;

  /// No description provided for @mapKpiPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get mapKpiPaused;

  /// No description provided for @mapKpiIssues.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get mapKpiIssues;

  /// No description provided for @mapStatusInDelivery.
  ///
  /// In en, this message translates to:
  /// **'In Delivery'**
  String get mapStatusInDelivery;

  /// No description provided for @mapStatusOnTheWayToLoad.
  ///
  /// In en, this message translates to:
  /// **'Heading to Pick Up'**
  String get mapStatusOnTheWayToLoad;

  /// No description provided for @mapStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get mapStatusPaused;

  /// No description provided for @mapLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get mapLocation;

  /// No description provided for @mapRemainingDistance.
  ///
  /// In en, this message translates to:
  /// **'Remaining Distance'**
  String get mapRemainingDistance;

  /// No description provided for @mapRemainingDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} Km'**
  String mapRemainingDistanceKm(String distance);

  /// No description provided for @mapNoDistance.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get mapNoDistance;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & Issues'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor and resolve exceptional issues'**
  String get supportSubtitle;

  /// No description provided for @supportCurrentArea.
  ///
  /// In en, this message translates to:
  /// **'Current Area'**
  String get supportCurrentArea;

  /// No description provided for @supportMissingIssues.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get supportMissingIssues;

  /// No description provided for @supportResolvingIssues.
  ///
  /// In en, this message translates to:
  /// **'Resolving'**
  String get supportResolvingIssues;

  /// No description provided for @supportResolvedIssues.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get supportResolvedIssues;

  /// No description provided for @supportIssuesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get supportIssuesCountLabel;

  /// No description provided for @supportTabOpen.
  ///
  /// In en, this message translates to:
  /// **'Open ({count})'**
  String supportTabOpen(int count);

  /// No description provided for @supportTabResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved ({count})'**
  String supportTabResolved(int count);

  /// No description provided for @supportTabResolving.
  ///
  /// In en, this message translates to:
  /// **'In Progress ({count})'**
  String supportTabResolving(int count);

  /// No description provided for @supportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by box number, driver name, or issue type'**
  String get supportSearchHint;

  /// No description provided for @supportFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All Areas'**
  String get supportFilterAll;

  /// No description provided for @supportFilterLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get supportFilterLast7Days;

  /// No description provided for @supportIssueLate.
  ///
  /// In en, this message translates to:
  /// **'Severe Delay'**
  String get supportIssueLate;

  /// No description provided for @supportIssueDamagedBox.
  ///
  /// In en, this message translates to:
  /// **'Damaged Box'**
  String get supportIssueDamagedBox;

  /// No description provided for @supportIssueCustomerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Customer Unavailable'**
  String get supportIssueCustomerUnavailable;

  /// No description provided for @supportIssueAddressProblem.
  ///
  /// In en, this message translates to:
  /// **'Address Problem'**
  String get supportIssueAddressProblem;

  /// No description provided for @supportTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String supportTimeMinutesAgo(int minutes);

  /// No description provided for @supportViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get supportViewDetails;

  /// No description provided for @supportAssignAlternativeDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Alternative Driver'**
  String get supportAssignAlternativeDriver;

  /// No description provided for @supportInfoBannerText.
  ///
  /// In en, this message translates to:
  /// **'You can contact the driver directly from the issue details to resolve it quickly'**
  String get supportInfoBannerText;

  /// No description provided for @supportEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No issues found'**
  String get supportEmptyTitle;

  /// No description provided for @supportEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no support issues matching your criteria.'**
  String get supportEmptyDescription;

  /// No description provided for @supportDateFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get supportDateFilterTitle;

  /// No description provided for @supportDatePresetToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get supportDatePresetToday;

  /// No description provided for @supportDatePresetYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get supportDatePresetYesterday;

  /// No description provided for @supportDatePresetLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get supportDatePresetLast7Days;

  /// No description provided for @supportDatePresetLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get supportDatePresetLast30Days;

  /// No description provided for @supportDatePresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get supportDatePresetCustom;

  /// No description provided for @supportApplyDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get supportApplyDateFilter;

  /// No description provided for @supportLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get supportLoadingMore;

  /// No description provided for @supportRetryLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more. Tap to retry.'**
  String get supportRetryLoadingMore;

  /// No description provided for @issueDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem Details'**
  String get issueDetailsTitle;

  /// No description provided for @issueDetailsUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get issueDetailsUrgent;

  /// No description provided for @issueDetailsReportedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Reported {minutes} minutes ago'**
  String issueDetailsReportedMinutesAgo(int minutes);

  /// No description provided for @issueDetailsTaskNumber.
  ///
  /// In en, this message translates to:
  /// **'Task Number'**
  String get issueDetailsTaskNumber;

  /// No description provided for @issueDetailsArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get issueDetailsArea;

  /// No description provided for @issueDetailsAffectedBoxes.
  ///
  /// In en, this message translates to:
  /// **'Affected Boxes'**
  String get issueDetailsAffectedBoxes;

  /// No description provided for @issueDetailsBoxesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Boxes'**
  String issueDetailsBoxesCount(int count);

  /// No description provided for @issueDetailsPriority.
  ///
  /// In en, this message translates to:
  /// **'Issue Priority'**
  String get issueDetailsPriority;

  /// No description provided for @issueDetailsPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get issueDetailsPriorityHigh;

  /// No description provided for @issueDetailsDriverData.
  ///
  /// In en, this message translates to:
  /// **'Driver Info'**
  String get issueDetailsDriverData;

  /// No description provided for @issueDetailsStatusNow.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get issueDetailsStatusNow;

  /// No description provided for @issueDetailsStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get issueDetailsStatusOnline;

  /// No description provided for @issueDetailsOnMission.
  ///
  /// In en, this message translates to:
  /// **'On Mission'**
  String get issueDetailsOnMission;

  /// No description provided for @issueDetailsDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get issueDetailsDescriptionTitle;

  /// No description provided for @issueDetailsAttachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments / Uploaded Image'**
  String get issueDetailsAttachmentsTitle;

  /// No description provided for @issueDetailsTripInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip / Order Information'**
  String get issueDetailsTripInfoTitle;

  /// No description provided for @issueDetailsClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get issueDetailsClient;

  /// No description provided for @issueDetailsMealsCount.
  ///
  /// In en, this message translates to:
  /// **'Meals Count'**
  String get issueDetailsMealsCount;

  /// No description provided for @issueDetailsMealsCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count} Meals'**
  String issueDetailsMealsCountValue(int count);

  /// No description provided for @issueDetailsExpectedDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery Time'**
  String get issueDetailsExpectedDeliveryTime;

  /// No description provided for @issueDetailsPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get issueDetailsPickupLocation;

  /// No description provided for @issueDetailsDropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get issueDetailsDropoffLocation;

  /// No description provided for @issueDetailsQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get issueDetailsQuickActions;

  /// No description provided for @issueDetailsAssignReplacementDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Replacement Driver'**
  String get issueDetailsAssignReplacementDriver;

  /// No description provided for @issueDetailsContactDriver.
  ///
  /// In en, this message translates to:
  /// **'Contact Driver'**
  String get issueDetailsContactDriver;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileSettingsTitle;

  /// No description provided for @profileAdminInfo.
  ///
  /// In en, this message translates to:
  /// **'Officer Information'**
  String get profileAdminInfo;

  /// No description provided for @profileDeliveryOfficer.
  ///
  /// In en, this message translates to:
  /// **'Delivery Officer'**
  String get profileDeliveryOfficer;

  /// No description provided for @profileAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get profileAvailableNow;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhoneNumber;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileNonEditable.
  ///
  /// In en, this message translates to:
  /// **'Non-editable'**
  String get profileNonEditable;

  /// No description provided for @profilePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get profilePassword;

  /// No description provided for @profileNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get profileNotificationSettings;

  /// No description provided for @profileNotifyNewBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'New Box Ready for Pickup'**
  String get profileNotifyNewBoxTitle;

  /// No description provided for @profileNotifyNewBoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification when new boxes are ready for pickup from restaurant'**
  String get profileNotifyNewBoxSubtitle;

  /// No description provided for @profileNotifyBoxProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Issue'**
  String get profileNotifyBoxProblemTitle;

  /// No description provided for @profileNotifyBoxProblemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification when damage or issue is reported with any box'**
  String get profileNotifyBoxProblemSubtitle;

  /// No description provided for @profileNotifyDriverFinishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Completed All Boxes'**
  String get profileNotifyDriverFinishedTitle;

  /// No description provided for @profileNotifyDriverFinishedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification when driver successfully completes all boxes'**
  String get profileNotifyDriverFinishedSubtitle;

  /// No description provided for @profileNotifyPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance Updates'**
  String get profileNotifyPerformanceTitle;

  /// No description provided for @profileNotifyPerformanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily performance summary and goal alerts'**
  String get profileNotifyPerformanceSubtitle;

  /// No description provided for @profileAppInfo.
  ///
  /// In en, this message translates to:
  /// **'Application Info'**
  String get profileAppInfo;

  /// No description provided for @profileAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get profileAppVersion;

  /// No description provided for @profileTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTermsConditions;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsTabAll;

  /// No description provided for @notificationsTabUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsTabUnread;

  /// No description provided for @notificationsTabArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get notificationsTabArchive;

  /// No description provided for @notificationsSectionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent Notifications'**
  String get notificationsSectionRecent;

  /// No description provided for @notificationsMarkAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllAsRead;

  /// No description provided for @homeStoreName.
  ///
  /// In en, this message translates to:
  /// **'MealMate Restaurant Kuwait'**
  String get homeStoreName;

  /// No description provided for @homeRoleDispatcher.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher'**
  String get homeRoleDispatcher;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeGreeting;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything is under control today 👋'**
  String get homeGreetingSubtitle;

  /// No description provided for @homeSectionQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeSectionQuickActions;

  /// No description provided for @homeActionAssignDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get homeActionAssignDriver;

  /// No description provided for @homeActionSolveIssues.
  ///
  /// In en, this message translates to:
  /// **'Solve Issues'**
  String get homeActionSolveIssues;

  /// No description provided for @homeActionDriversMap.
  ///
  /// In en, this message translates to:
  /// **'Drivers Map'**
  String get homeActionDriversMap;

  /// No description provided for @homeActionAllDrivers.
  ///
  /// In en, this message translates to:
  /// **'All Drivers'**
  String get homeActionAllDrivers;

  /// No description provided for @homeDriversMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Drivers Locations'**
  String get homeDriversMapTitle;

  /// No description provided for @homeDriversMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time driver monitoring'**
  String get homeDriversMapSubtitle;

  /// No description provided for @homeViewFullMap.
  ///
  /// In en, this message translates to:
  /// **'View Full Map'**
  String get homeViewFullMap;

  /// No description provided for @homeOperationsStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations Status'**
  String get homeOperationsStatusTitle;

  /// No description provided for @homeCompletionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get homeCompletionRate;

  /// No description provided for @homeViewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get homeViewReports;

  /// No description provided for @homeDriversReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Drivers Review'**
  String get homeDriversReviewTitle;

  /// No description provided for @homeViewAllDrivers.
  ///
  /// In en, this message translates to:
  /// **'View All Drivers'**
  String get homeViewAllDrivers;

  /// No description provided for @homeAreaSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Area Summary'**
  String get homeAreaSummaryTitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @homeUnitOrder.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get homeUnitOrder;

  /// No description provided for @homeKpiTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders Today'**
  String get homeKpiTotalOrders;

  /// No description provided for @homeKpiInDelivery.
  ///
  /// In en, this message translates to:
  /// **'In Delivery'**
  String get homeKpiInDelivery;

  /// No description provided for @homeKpiPendingAssignment.
  ///
  /// In en, this message translates to:
  /// **'Pending Assignment'**
  String get homeKpiPendingAssignment;

  /// No description provided for @homeKpiActiveIssues.
  ///
  /// In en, this message translates to:
  /// **'Active Issues'**
  String get homeKpiActiveIssues;

  /// No description provided for @homeOpDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get homeOpDelivered;

  /// No description provided for @homeOpInDelivery.
  ///
  /// In en, this message translates to:
  /// **'In Delivery'**
  String get homeOpInDelivery;

  /// No description provided for @homeOpPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Assignment'**
  String get homeOpPending;

  /// No description provided for @homeOpCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get homeOpCancelled;

  /// No description provided for @homeAlertActiveIssues.
  ///
  /// In en, this message translates to:
  /// **'{count} issues need your attention'**
  String homeAlertActiveIssues(int count);

  /// No description provided for @homeMapNoDrivers.
  ///
  /// In en, this message translates to:
  /// **'No drivers available'**
  String get homeMapNoDrivers;

  /// No description provided for @homeMapNoDriversDesc.
  ///
  /// In en, this message translates to:
  /// **'Driver locations will appear here.'**
  String get homeMapNoDriversDesc;

  /// No description provided for @homeNoTopDrivers.
  ///
  /// In en, this message translates to:
  /// **'No drivers data available'**
  String get homeNoTopDrivers;

  /// No description provided for @homeNoAreas.
  ///
  /// In en, this message translates to:
  /// **'No areas data available'**
  String get homeNoAreas;

  /// No description provided for @driverDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Details'**
  String get driverDetailsTitle;

  /// No description provided for @driverDetailsStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get driverDetailsStatusAvailable;

  /// No description provided for @driverDetailsLastUpdatedNow.
  ///
  /// In en, this message translates to:
  /// **'Last updated now'**
  String get driverDetailsLastUpdatedNow;

  /// No description provided for @driverDetailsKpiCurrentBoxes.
  ///
  /// In en, this message translates to:
  /// **'Current Boxes'**
  String get driverDetailsKpiCurrentBoxes;

  /// No description provided for @driverDetailsKpiDeliveredToday.
  ///
  /// In en, this message translates to:
  /// **'Delivered Today'**
  String get driverDetailsKpiDeliveredToday;

  /// No description provided for @driverDetailsKpiAvgDelay.
  ///
  /// In en, this message translates to:
  /// **'Avg Delay (m)'**
  String get driverDetailsKpiAvgDelay;

  /// No description provided for @driverDetailsKpiRating.
  ///
  /// In en, this message translates to:
  /// **'Performance Rating'**
  String get driverDetailsKpiRating;

  /// No description provided for @driverDetailsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get driverDetailsLocationTitle;

  /// No description provided for @driverDetailsStatusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get driverDetailsStatusOutForDelivery;

  /// No description provided for @driverDetailsStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get driverDetailsStatusReceived;

  /// No description provided for @driverDetailsTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String driverDetailsTimeAgo(int minutes);

  /// No description provided for @driverDetailsOpenOnMap.
  ///
  /// In en, this message translates to:
  /// **'Open on Map'**
  String get driverDetailsOpenOnMap;

  /// No description provided for @driverDetailsActiveBoxesTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Boxes ({count})'**
  String driverDetailsActiveBoxesTitle(int count);

  /// No description provided for @driverDetailsAppointment.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get driverDetailsAppointment;

  /// No description provided for @driverDetailsClient.
  ///
  /// In en, this message translates to:
  /// **'Client: {name}'**
  String driverDetailsClient(String name);

  /// No description provided for @driverDetailsDailyPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Performance Summary'**
  String get driverDetailsDailyPerformanceTitle;

  /// No description provided for @driverDetailsApproxKm.
  ///
  /// In en, this message translates to:
  /// **'Approx Km'**
  String get driverDetailsApproxKm;

  /// No description provided for @driverDetailsAvgDelayMin.
  ///
  /// In en, this message translates to:
  /// **'Avg Delay'**
  String get driverDetailsAvgDelayMin;

  /// No description provided for @driverDetailsDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Delivery Failed'**
  String get driverDetailsDeliveryFailed;

  /// No description provided for @driverDetailsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get driverDetailsDelivered;

  /// No description provided for @driverDetailsSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get driverDetailsSendMessage;

  /// No description provided for @driverDetailsCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get driverDetailsCall;

  /// No description provided for @boxTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Tracking'**
  String get boxTrackingTitle;

  /// No description provided for @boxTrackingCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String boxTrackingCustomerLabel(String name);

  /// No description provided for @boxTrackingStatusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get boxTrackingStatusOnTheWay;

  /// No description provided for @boxTrackingStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready at restaurant'**
  String get boxTrackingStatusReady;

  /// No description provided for @boxTrackingStatusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up by driver'**
  String get boxTrackingStatusPickedUp;

  /// No description provided for @boxTrackingStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get boxTrackingStatusDelivered;

  /// No description provided for @boxTrackingTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Status'**
  String get boxTrackingTimelineTitle;

  /// No description provided for @boxTrackingLiveTrack.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get boxTrackingLiveTrack;

  /// No description provided for @boxTrackingSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get boxTrackingSendMessage;

  /// No description provided for @boxTrackingCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get boxTrackingCall;

  /// No description provided for @boxTrackingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Details'**
  String get boxTrackingDetailsTitle;

  /// No description provided for @boxTrackingPlanType.
  ///
  /// In en, this message translates to:
  /// **'Plan Type'**
  String get boxTrackingPlanType;

  /// No description provided for @boxTrackingOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get boxTrackingOrderDate;

  /// No description provided for @boxTrackingMealCount.
  ///
  /// In en, this message translates to:
  /// **'Meal Count'**
  String get boxTrackingMealCount;

  /// No description provided for @boxTrackingCustomerNotes.
  ///
  /// In en, this message translates to:
  /// **'Customer Notes'**
  String get boxTrackingCustomerNotes;

  /// No description provided for @boxTrackingReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue with the box'**
  String get boxTrackingReportIssue;

  /// No description provided for @boxTrackingDriverRole.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get boxTrackingDriverRole;

  /// No description provided for @reassignDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Replacement Driver'**
  String get reassignDriverTitle;

  /// No description provided for @reassignDriverProblemSummary.
  ///
  /// In en, this message translates to:
  /// **'Problem Summary'**
  String get reassignDriverProblemSummary;

  /// No description provided for @reassignDriverTaskNumber.
  ///
  /// In en, this message translates to:
  /// **'Task Number'**
  String get reassignDriverTaskNumber;

  /// No description provided for @reassignDriverArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get reassignDriverArea;

  /// No description provided for @reassignDriverAffectedBoxes.
  ///
  /// In en, this message translates to:
  /// **'Affected Boxes'**
  String get reassignDriverAffectedBoxes;

  /// No description provided for @reassignDriverPriority.
  ///
  /// In en, this message translates to:
  /// **'Problem Priority'**
  String get reassignDriverPriority;

  /// No description provided for @reassignDriverCurrentDriver.
  ///
  /// In en, this message translates to:
  /// **'Current Driver'**
  String get reassignDriverCurrentDriver;

  /// No description provided for @reassignDriverUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get reassignDriverUnavailable;

  /// No description provided for @reassignDriverVehicleFailureReason.
  ///
  /// In en, this message translates to:
  /// **'Driver is unable to complete the order due to vehicle breakdown'**
  String get reassignDriverVehicleFailureReason;

  /// No description provided for @reassignDriverSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Replacement Driver'**
  String get reassignDriverSelectTitle;

  /// No description provided for @reassignDriverSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available drivers in the same area are shown first'**
  String get reassignDriverSelectSubtitle;

  /// No description provided for @reassignDriverFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get reassignDriverFilter;

  /// No description provided for @reassignDriverAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'Available Now'**
  String get reassignDriverAvailableNow;

  /// No description provided for @reassignDriverOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String reassignDriverOrdersCount(int count);

  /// No description provided for @reassignDriverFromYourLocation.
  ///
  /// In en, this message translates to:
  /// **'From your location'**
  String get reassignDriverFromYourLocation;

  /// No description provided for @reassignDriverConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Driver Selection'**
  String get reassignDriverConfirm;

  /// No description provided for @reassignDriverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Replacement driver assigned successfully'**
  String get reassignDriverSuccess;

  /// No description provided for @driverFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Drivers'**
  String get driverFilterTitle;

  /// No description provided for @driverFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select suitable filters to display results'**
  String get driverFilterSubtitle;

  /// No description provided for @driverFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get driverFilterReset;

  /// No description provided for @driverFilterClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get driverFilterClose;

  /// No description provided for @driverFilterByArea.
  ///
  /// In en, this message translates to:
  /// **'By Area'**
  String get driverFilterByArea;

  /// No description provided for @driverFilterAllAreas.
  ///
  /// In en, this message translates to:
  /// **'All Areas'**
  String get driverFilterAllAreas;

  /// No description provided for @driverFilterSalmiya.
  ///
  /// In en, this message translates to:
  /// **'Salmiya'**
  String get driverFilterSalmiya;

  /// No description provided for @driverFilterHawalli.
  ///
  /// In en, this message translates to:
  /// **'Hawalli'**
  String get driverFilterHawalli;

  /// No description provided for @driverFilterHiteen.
  ///
  /// In en, this message translates to:
  /// **'Hiteen'**
  String get driverFilterHiteen;

  /// No description provided for @driverFilterFarwaniya.
  ///
  /// In en, this message translates to:
  /// **'Farwaniya'**
  String get driverFilterFarwaniya;

  /// No description provided for @driverFilterCapital.
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get driverFilterCapital;

  /// No description provided for @driverFilterByStatus.
  ///
  /// In en, this message translates to:
  /// **'By Status'**
  String get driverFilterByStatus;

  /// No description provided for @driverFilterAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get driverFilterAllStatuses;

  /// No description provided for @driverFilterStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get driverFilterStatusAvailable;

  /// No description provided for @driverFilterStatusBusyNow.
  ///
  /// In en, this message translates to:
  /// **'Busy Now'**
  String get driverFilterStatusBusyNow;

  /// No description provided for @driverFilterStatusOnWay.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get driverFilterStatusOnWay;

  /// No description provided for @driverFilterStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get driverFilterStatusUnavailable;

  /// No description provided for @driverFilterByRating.
  ///
  /// In en, this message translates to:
  /// **'By Rating'**
  String get driverFilterByRating;

  /// No description provided for @driverFilterAllRatings.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get driverFilterAllRatings;

  /// No description provided for @driverFilterRating4Point5Plus.
  ///
  /// In en, this message translates to:
  /// **'4.5 & up'**
  String get driverFilterRating4Point5Plus;

  /// No description provided for @driverFilterRating4Plus.
  ///
  /// In en, this message translates to:
  /// **'4 & up'**
  String get driverFilterRating4Plus;

  /// No description provided for @driverFilterRating3Plus.
  ///
  /// In en, this message translates to:
  /// **'3 & up'**
  String get driverFilterRating3Plus;

  /// No description provided for @driverFilterRating2Plus.
  ///
  /// In en, this message translates to:
  /// **'2 & up'**
  String get driverFilterRating2Plus;

  /// No description provided for @driverFilterRating1Plus.
  ///
  /// In en, this message translates to:
  /// **'1 & up'**
  String get driverFilterRating1Plus;

  /// No description provided for @driverFilterByDistance.
  ///
  /// In en, this message translates to:
  /// **'By Distance'**
  String get driverFilterByDistance;

  /// No description provided for @driverFilterDistance0Km.
  ///
  /// In en, this message translates to:
  /// **'0 km'**
  String get driverFilterDistance0Km;

  /// No description provided for @driverFilterDistance50PlusKm.
  ///
  /// In en, this message translates to:
  /// **'+50 km'**
  String get driverFilterDistance50PlusKm;

  /// No description provided for @driverFilterDistanceRange5.
  ///
  /// In en, this message translates to:
  /// **'0-5 km'**
  String get driverFilterDistanceRange5;

  /// No description provided for @driverFilterDistanceRange10.
  ///
  /// In en, this message translates to:
  /// **'5-10 km'**
  String get driverFilterDistanceRange10;

  /// No description provided for @driverFilterDistanceRange20.
  ///
  /// In en, this message translates to:
  /// **'10-20 km'**
  String get driverFilterDistanceRange20;

  /// No description provided for @driverFilterDistanceRange50.
  ///
  /// In en, this message translates to:
  /// **'20-50 km'**
  String get driverFilterDistanceRange50;

  /// No description provided for @driverFilterByCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'By Completed Orders'**
  String get driverFilterByCompletedOrders;

  /// No description provided for @driverFilterOrders0.
  ///
  /// In en, this message translates to:
  /// **'0 orders'**
  String get driverFilterOrders0;

  /// No description provided for @driverFilterOrders1000Plus.
  ///
  /// In en, this message translates to:
  /// **'+1000 orders'**
  String get driverFilterOrders1000Plus;

  /// No description provided for @driverFilterOrdersRange20.
  ///
  /// In en, this message translates to:
  /// **'0-20'**
  String get driverFilterOrdersRange20;

  /// No description provided for @driverFilterOrdersRange50.
  ///
  /// In en, this message translates to:
  /// **'20-50'**
  String get driverFilterOrdersRange50;

  /// No description provided for @driverFilterOrdersRange100.
  ///
  /// In en, this message translates to:
  /// **'50-100'**
  String get driverFilterOrdersRange100;

  /// No description provided for @driverFilterOrdersRange500.
  ///
  /// In en, this message translates to:
  /// **'100-500'**
  String get driverFilterOrdersRange500;

  /// No description provided for @driverFilterOrdersRange500Plus.
  ///
  /// In en, this message translates to:
  /// **'+500'**
  String get driverFilterOrdersRange500Plus;

  /// No description provided for @driverFilterSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by Driver Name or ID'**
  String get driverFilterSearchTitle;

  /// No description provided for @driverFilterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type driver name or ID...'**
  String get driverFilterSearchHint;

  /// No description provided for @driverFilterResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get driverFilterResetAll;

  /// No description provided for @driverFilterShowResults.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get driverFilterShowResults;

  /// No description provided for @driverFilterShowAllDrivers.
  ///
  /// In en, this message translates to:
  /// **'Show all drivers'**
  String get driverFilterShowAllDrivers;

  /// No description provided for @operationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations Log'**
  String get operationsTitle;

  /// No description provided for @operationsFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get operationsFilter;

  /// No description provided for @operationsSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by box number, driver, or customer...'**
  String get operationsSearchPlaceholder;

  /// No description provided for @operationsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get operationsLast7Days;

  /// No description provided for @operationsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get operationsTabAll;

  /// No description provided for @operationsTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get operationsTabCompleted;

  /// No description provided for @operationsTabCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get operationsTabCancelled;

  /// No description provided for @operationsTabFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed Delivery'**
  String get operationsTabFailed;

  /// No description provided for @operationsTabReassigned.
  ///
  /// In en, this message translates to:
  /// **'Reassigned'**
  String get operationsTabReassigned;

  /// No description provided for @operationsCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer:'**
  String get operationsCustomerLabel;

  /// No description provided for @operationsCancelledByRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by restaurant'**
  String get operationsCancelledByRestaurant;

  /// No description provided for @operationsPrevPage.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get operationsPrevPage;

  /// No description provided for @operationsNextPage.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get operationsNextPage;

  /// No description provided for @operationsPageOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get operationsPageOf;

  /// No description provided for @profileOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations Log'**
  String get profileOperationsTitle;

  /// No description provided for @profileOperationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and track past delivery orders and operations'**
  String get profileOperationsSubtitle;

  /// No description provided for @profileDriverPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Performance'**
  String get profileDriverPerformanceTitle;

  /// No description provided for @profileDriverPerformanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor driver metrics and delivery performance'**
  String get profileDriverPerformanceSubtitle;

  /// No description provided for @driverPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Performance'**
  String get driverPerformanceTitle;

  /// No description provided for @driverPerformanceLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get driverPerformanceLast7Days;

  /// No description provided for @driverPerformanceTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get driverPerformanceTabOverview;

  /// No description provided for @driverPerformanceTabCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare Drivers'**
  String get driverPerformanceTabCompare;

  /// No description provided for @driverPerformanceTotalBoxes.
  ///
  /// In en, this message translates to:
  /// **'Total Boxes'**
  String get driverPerformanceTotalBoxes;

  /// No description provided for @driverPerformanceDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get driverPerformanceDelivered;

  /// No description provided for @driverPerformanceAvgDelay.
  ///
  /// In en, this message translates to:
  /// **'Avg Delay'**
  String get driverPerformanceAvgDelay;

  /// No description provided for @driverPerformanceOverallRating.
  ///
  /// In en, this message translates to:
  /// **'Overall Rating'**
  String get driverPerformanceOverallRating;

  /// No description provided for @driverPerformanceDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed Delivery'**
  String get driverPerformanceDeliveryFailed;

  /// No description provided for @driverPerformanceBoxesUnit.
  ///
  /// In en, this message translates to:
  /// **'Boxes'**
  String get driverPerformanceBoxesUnit;

  /// No description provided for @driverPerformanceMinutesUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get driverPerformanceMinutesUnit;

  /// No description provided for @driverPerformanceOutOfFive.
  ///
  /// In en, this message translates to:
  /// **'out of 5'**
  String get driverPerformanceOutOfFive;

  /// No description provided for @driverPerformanceDriversSection.
  ///
  /// In en, this message translates to:
  /// **'Driver Performance'**
  String get driverPerformanceDriversSection;

  /// No description provided for @driverPerformanceColDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverPerformanceColDriver;

  /// No description provided for @driverPerformanceColDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get driverPerformanceColDelivered;

  /// No description provided for @driverPerformanceColAvgDelay.
  ///
  /// In en, this message translates to:
  /// **'Avg Delay'**
  String get driverPerformanceColAvgDelay;

  /// No description provided for @driverPerformanceColDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed Delivery'**
  String get driverPerformanceColDeliveryFailed;

  /// No description provided for @driverPerformanceColRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get driverPerformanceColRating;

  /// No description provided for @driverPerformanceMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String driverPerformanceMinutesShort(int minutes);

  /// No description provided for @driverPerformanceDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance Distribution'**
  String get driverPerformanceDistributionTitle;

  /// No description provided for @driverPerformanceDistributionOrderCol.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get driverPerformanceDistributionOrderCol;

  /// No description provided for @driverPerformanceDistributionPctCol.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get driverPerformanceDistributionPctCol;

  /// No description provided for @driverPerformanceDistributionCenterSub.
  ///
  /// In en, this message translates to:
  /// **'Boxes'**
  String get driverPerformanceDistributionCenterSub;

  /// No description provided for @driverPerformanceDistOnTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get driverPerformanceDistOnTime;

  /// No description provided for @driverPerformanceDistLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get driverPerformanceDistLate;

  /// No description provided for @driverPerformanceDistFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed Delivery'**
  String get driverPerformanceDistFailed;

  /// No description provided for @driverPerformanceDistCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get driverPerformanceDistCancelled;

  /// No description provided for @driverPerformanceTopRatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Drivers'**
  String get driverPerformanceTopRatedTitle;

  /// No description provided for @driverBoxesTitle.
  ///
  /// In en, this message translates to:
  /// **'Boxes List'**
  String get driverBoxesTitle;

  /// No description provided for @driverBoxesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned boxes before delivery'**
  String get driverBoxesSubtitle;

  /// No description provided for @driverInDeliveryMode.
  ///
  /// In en, this message translates to:
  /// **'You are in delivery mode'**
  String get driverInDeliveryMode;

  /// No description provided for @driverTotalMeals.
  ///
  /// In en, this message translates to:
  /// **'Total Meals'**
  String get driverTotalMeals;

  /// No description provided for @driverMealsUnit.
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get driverMealsUnit;

  /// No description provided for @driverTotalBoxesToday.
  ///
  /// In en, this message translates to:
  /// **'Total boxes assigned today'**
  String get driverTotalBoxesToday;

  /// No description provided for @driverBoxesUnit.
  ///
  /// In en, this message translates to:
  /// **'boxes'**
  String get driverBoxesUnit;

  /// No description provided for @driverBoxesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get driverBoxesFilterAll;

  /// No description provided for @driverBoxesFilterNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Not Loaded'**
  String get driverBoxesFilterNotLoaded;

  /// No description provided for @driverBoxesFilterLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded'**
  String get driverBoxesFilterLoaded;

  /// No description provided for @driverMealCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Meals Count'**
  String get driverMealCountLabel;

  /// No description provided for @driverAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get driverAreaLabel;

  /// No description provided for @driverStatusNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Not Loaded'**
  String get driverStatusNotLoaded;

  /// No description provided for @driverStatusLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded'**
  String get driverStatusLoaded;

  /// No description provided for @driverCompleteAction.
  ///
  /// In en, this message translates to:
  /// **'Complete\nAction'**
  String get driverCompleteAction;

  /// No description provided for @driverBoxCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Box ID copied to clipboard'**
  String get driverBoxCopiedToClipboard;

  /// No description provided for @driverBoxesFilterReadyForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Ready for delivery'**
  String get driverBoxesFilterReadyForDelivery;

  /// No description provided for @driverBoxesFilterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get driverBoxesFilterDelivered;

  /// No description provided for @driverStatusReadyForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Ready for delivery'**
  String get driverStatusReadyForDelivery;

  /// No description provided for @driverStatusIssueOccurred.
  ///
  /// In en, this message translates to:
  /// **'Problem occurred'**
  String get driverStatusIssueOccurred;

  /// No description provided for @driverActionStartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start delivery'**
  String get driverActionStartDelivery;

  /// No description provided for @driverActionDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get driverActionDelivered;

  /// No description provided for @driverActionDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Delivery failed'**
  String get driverActionDeliveryFailed;

  /// No description provided for @driverConfirmReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order Receipt'**
  String get driverConfirmReceiptTitle;

  /// No description provided for @driverStepScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get driverStepScanQr;

  /// No description provided for @driverStepPhotographBox.
  ///
  /// In en, this message translates to:
  /// **'Photograph Box'**
  String get driverStepPhotographBox;

  /// No description provided for @driverStepOrderMandatoryNote.
  ///
  /// In en, this message translates to:
  /// **'Mandatory order: Scan QR first, then photograph box'**
  String get driverStepOrderMandatoryNote;

  /// No description provided for @driverQrScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get driverQrScannerTitle;

  /// No description provided for @driverQrScannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code on the meal box'**
  String get driverQrScannerSubtitle;

  /// No description provided for @driverFlashToggle.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get driverFlashToggle;

  /// No description provided for @driverQrViewfinderHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code on the box'**
  String get driverQrViewfinderHint;

  /// No description provided for @driverOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get driverOrDivider;

  /// No description provided for @driverEnterCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter code manually'**
  String get driverEnterCodeManually;

  /// No description provided for @driverStep2ActivatedAfterScan.
  ///
  /// In en, this message translates to:
  /// **'Activated after successful scan'**
  String get driverStep2ActivatedAfterScan;

  /// No description provided for @driverContinueToPhotographBox.
  ///
  /// In en, this message translates to:
  /// **'Continue to Photograph Box'**
  String get driverContinueToPhotographBox;

  /// No description provided for @driverPhotographBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Photograph Box'**
  String get driverPhotographBoxTitle;

  /// No description provided for @driverPhotographBoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the full box'**
  String get driverPhotographBoxSubtitle;

  /// No description provided for @driverCameraBoxLightingHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure the full box is visible and lighting is suitable'**
  String get driverCameraBoxLightingHint;

  /// No description provided for @driverTakePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get driverTakePhotoAction;

  /// No description provided for @driverConfirmDeliveryAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Receipt'**
  String get driverConfirmDeliveryAction;

  /// No description provided for @driverBoxVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Box receipt confirmed successfully'**
  String get driverBoxVerifiedSuccess;

  /// No description provided for @driverBoxesReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Boxes Received'**
  String get driverBoxesReceivedTitle;

  /// No description provided for @driverBoxesReceivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All boxes received successfully from assembly point'**
  String get driverBoxesReceivedSubtitle;

  /// No description provided for @driverBoxesReceivedSuccessCount.
  ///
  /// In en, this message translates to:
  /// **'5 Boxes Received Successfully'**
  String get driverBoxesReceivedSuccessCount;

  /// No description provided for @driverBoxesReceivedReadySub.
  ///
  /// In en, this message translates to:
  /// **'Ready to start your first delivery'**
  String get driverBoxesReceivedReadySub;

  /// No description provided for @driverAssemblyPoint.
  ///
  /// In en, this message translates to:
  /// **'Assembly Point'**
  String get driverAssemblyPoint;

  /// No description provided for @driverAssemblyPointValue.
  ///
  /// In en, this message translates to:
  /// **'Meal Center - Al Narjis'**
  String get driverAssemblyPointValue;

  /// No description provided for @driverReceiptTime.
  ///
  /// In en, this message translates to:
  /// **'Pickup Time'**
  String get driverReceiptTime;

  /// No description provided for @driverReceiptTimeValue.
  ///
  /// In en, this message translates to:
  /// **'09:06 AM'**
  String get driverReceiptTimeValue;

  /// No description provided for @driverReadyForDeliveryRoute.
  ///
  /// In en, this message translates to:
  /// **'Ready for Delivery'**
  String get driverReadyForDeliveryRoute;

  /// No description provided for @driverReadyForDeliveryRouteValue.
  ///
  /// In en, this message translates to:
  /// **'Route 1'**
  String get driverReadyForDeliveryRouteValue;

  /// No description provided for @driverReceivedBoxesTitle.
  ///
  /// In en, this message translates to:
  /// **'Received Boxes'**
  String get driverReceivedBoxesTitle;

  /// No description provided for @driverBoxesCountBadge.
  ///
  /// In en, this message translates to:
  /// **'5 Boxes'**
  String get driverBoxesCountBadge;

  /// No description provided for @driverBoxConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Box condition:'**
  String get driverBoxConditionLabel;

  /// No description provided for @driverBoxConditionValue.
  ///
  /// In en, this message translates to:
  /// **'Intact & Ready'**
  String get driverBoxConditionValue;

  /// No description provided for @driverBoxStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get driverBoxStatusReceived;

  /// No description provided for @driverBoxesDeliverySafetyTip.
  ///
  /// In en, this message translates to:
  /// **'Ensure boxes are well secured in your vehicle to avoid damage while driving'**
  String get driverBoxesDeliverySafetyTip;

  /// No description provided for @driverStartDeliveryButton.
  ///
  /// In en, this message translates to:
  /// **'Start Delivery'**
  String get driverStartDeliveryButton;

  /// No description provided for @driverProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Support'**
  String get driverProfileTitle;

  /// No description provided for @driverProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your info and get assistance'**
  String get driverProfileSubtitle;

  /// No description provided for @driverStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get driverStatusOnline;

  /// No description provided for @driverIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driverIdLabel;

  /// No description provided for @driverRatingReviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get driverRatingReviews;

  /// No description provided for @driverTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get driverTotalOrders;

  /// No description provided for @driverAcceptanceRate.
  ///
  /// In en, this message translates to:
  /// **'Acceptance Rate'**
  String get driverAcceptanceRate;

  /// No description provided for @driverRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get driverRating;

  /// No description provided for @driverMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get driverMemberSince;

  /// No description provided for @driverVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get driverVehicleInfo;

  /// No description provided for @driverVehicleActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get driverVehicleActive;

  /// No description provided for @driverVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get driverVehicleType;

  /// No description provided for @driverVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get driverVehicleModel;

  /// No description provided for @driverPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get driverPlateNumber;

  /// No description provided for @driverSupportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get driverSupportSectionTitle;

  /// No description provided for @driverContactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get driverContactSupportTitle;

  /// No description provided for @driverContactSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Support team is available 24/7 to assist you'**
  String get driverContactSupportDesc;

  /// No description provided for @driverRecentTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Support Request Status'**
  String get driverRecentTicketTitle;

  /// No description provided for @driverViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get driverViewAll;

  /// No description provided for @driverTicketStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get driverTicketStatusResolved;

  /// No description provided for @driverQuickActionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get driverQuickActionLanguage;

  /// No description provided for @driverQuickActionLanguageValue.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get driverQuickActionLanguageValue;

  /// No description provided for @driverQuickActionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get driverQuickActionSettings;

  /// No description provided for @driverQuickActionSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get driverQuickActionSettingsDesc;

  /// No description provided for @driverQuickActionLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get driverQuickActionLogout;

  /// No description provided for @driverQuickActionLogoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of account'**
  String get driverQuickActionLogoutDesc;

  /// No description provided for @driverDeliveryPolicyTip.
  ///
  /// In en, this message translates to:
  /// **'All orders must be delivered manually to the client only'**
  String get driverDeliveryPolicyTip;

  /// No description provided for @driverLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get driverLogoutConfirmTitle;

  /// No description provided for @driverLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get driverLogoutConfirmMessage;

  /// No description provided for @driverNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get driverNotificationsTitle;

  /// No description provided for @driverNotificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get driverNotificationsFilterAll;

  /// No description provided for @driverNotificationsFilterDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery Orders'**
  String get driverNotificationsFilterDelivery;

  /// No description provided for @driverNotificationsFilterOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get driverNotificationsFilterOffers;

  /// No description provided for @driverNotificationsFilterSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get driverNotificationsFilterSystem;

  /// No description provided for @driverNotificationsSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get driverNotificationsSectionToday;

  /// No description provided for @driverNotificationsSectionYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get driverNotificationsSectionYesterday;

  /// No description provided for @driverNotificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get driverNotificationsMarkAllRead;

  /// No description provided for @driverNotificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications currently'**
  String get driverNotificationsEmpty;

  /// No description provided for @driverNotificationsMarkedAllReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get driverNotificationsMarkedAllReadSuccess;

  /// No description provided for @driverSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get driverSettingsTitle;

  /// No description provided for @driverSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferences and app settings'**
  String get driverSettingsSubtitle;

  /// No description provided for @driverSettingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get driverSettingsEditProfile;

  /// No description provided for @driverSettingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get driverSettingsAccountSection;

  /// No description provided for @driverSettingsPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get driverSettingsPersonalInfo;

  /// No description provided for @driverSettingsVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get driverSettingsVehicleInfo;

  /// No description provided for @driverSettingsMyDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get driverSettingsMyDocuments;

  /// No description provided for @driverSettingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get driverSettingsChangePassword;

  /// No description provided for @driverSettingsAppSection.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get driverSettingsAppSection;

  /// No description provided for @driverSettingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get driverSettingsLanguage;

  /// No description provided for @driverSettingsLanguageValue.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get driverSettingsLanguageValue;

  /// No description provided for @driverSettingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get driverSettingsNotifications;

  /// No description provided for @driverSettingsSounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get driverSettingsSounds;

  /// No description provided for @driverSettingsSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get driverSettingsSupportSection;

  /// No description provided for @driverSettingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get driverSettingsHelpCenter;

  /// No description provided for @driverSettingsContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get driverSettingsContactUs;

  /// No description provided for @driverSettingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get driverSettingsAboutApp;

  /// No description provided for @driverSettingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy & Terms'**
  String get driverSettingsPrivacyPolicy;

  /// No description provided for @driverSettingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get driverSettingsLogout;

  /// No description provided for @driverSettingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 2.4.1'**
  String get driverSettingsAppVersion;

  /// No description provided for @driverVehicleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get driverVehicleDetailsTitle;

  /// No description provided for @driverVehicleDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can view or edit your vehicle details'**
  String get driverVehicleDetailsSubtitle;

  /// No description provided for @driverVehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get driverVehicleTypeLabel;

  /// No description provided for @driverVehicleModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get driverVehicleModelLabel;

  /// No description provided for @driverVehicleColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get driverVehicleColorLabel;

  /// No description provided for @driverEditVehicleColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Color'**
  String get driverEditVehicleColorLabel;

  /// No description provided for @driverVehicleYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Manufacture Year'**
  String get driverVehicleYearLabel;

  /// No description provided for @driverVehicleStructureLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Type'**
  String get driverVehicleStructureLabel;

  /// No description provided for @driverVehicleChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get driverVehicleChangePhoto;

  /// No description provided for @driverVehiclePlateTitle.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get driverVehiclePlateTitle;

  /// No description provided for @driverVehicleKuwaitState.
  ///
  /// In en, this message translates to:
  /// **'State of Kuwait'**
  String get driverVehicleKuwaitState;

  /// No description provided for @driverVehicleKuwaitEn.
  ///
  /// In en, this message translates to:
  /// **'KUWAIT'**
  String get driverVehicleKuwaitEn;

  /// No description provided for @driverVehicleLicenseNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get driverVehicleLicenseNumberLabel;

  /// No description provided for @driverVehicleLicenseExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'License Expiry Date'**
  String get driverVehicleLicenseExpiryLabel;

  /// No description provided for @driverVehicleNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get driverVehicleNoticeTitle;

  /// No description provided for @driverVehicleNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Please ensure vehicle data is always up to date to guarantee work continuity and avoid account suspension.'**
  String get driverVehicleNoticeBody;

  /// No description provided for @driverVehicleEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get driverVehicleEditButton;

  /// No description provided for @driverEditVehicleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle Details'**
  String get driverEditVehicleDetailsTitle;

  /// No description provided for @driverEditVehicleDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your vehicle details'**
  String get driverEditVehicleDetailsSubtitle;

  /// No description provided for @driverEditVehiclePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Photo'**
  String get driverEditVehiclePhotoTitle;

  /// No description provided for @driverEditVehiclePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a clear photo of your vehicle'**
  String get driverEditVehiclePhotoSubtitle;

  /// No description provided for @driverEditVehicleNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (Optional)'**
  String get driverEditVehicleNotesLabel;

  /// No description provided for @driverEditVehicleNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes here...'**
  String get driverEditVehicleNotesHint;

  /// No description provided for @driverEditVehicleCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get driverEditVehicleCancel;

  /// No description provided for @driverEditVehicleSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get driverEditVehicleSaveChanges;

  /// No description provided for @driverEditVehicleSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Vehicle details updated successfully'**
  String get driverEditVehicleSuccessMessage;

  /// No description provided for @driverSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get driverSupportTitle;

  /// No description provided for @driverSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are here to help you anytime'**
  String get driverSupportSubtitle;

  /// No description provided for @driverSupportContactMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Methods'**
  String get driverSupportContactMethodsTitle;

  /// No description provided for @driverSupportCallUs.
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get driverSupportCallUs;

  /// No description provided for @driverSupportPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'800 123 4567'**
  String get driverSupportPhoneNumber;

  /// No description provided for @driverSupportCallHours.
  ///
  /// In en, this message translates to:
  /// **'Available 8 AM - 10 PM'**
  String get driverSupportCallHours;

  /// No description provided for @driverSupportEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get driverSupportEmail;

  /// No description provided for @driverSupportEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'support@Resturant.com'**
  String get driverSupportEmailAddress;

  /// No description provided for @driverSupportEmailTurnaround.
  ///
  /// In en, this message translates to:
  /// **'Response within 24h'**
  String get driverSupportEmailTurnaround;

  /// No description provided for @driverSupportFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Common Topics'**
  String get driverSupportFaqTitle;

  /// No description provided for @driverSupportTopicDeliveryIssue.
  ///
  /// In en, this message translates to:
  /// **'Order Delivery Issue'**
  String get driverSupportTopicDeliveryIssue;

  /// No description provided for @driverSupportTopicDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Delay, missing package, or address problem'**
  String get driverSupportTopicDeliveryDesc;

  /// No description provided for @driverSupportTopicAppIssue.
  ///
  /// In en, this message translates to:
  /// **'App Issue'**
  String get driverSupportTopicAppIssue;

  /// No description provided for @driverSupportTopicAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Glitches, login, or technical errors'**
  String get driverSupportTopicAppDesc;

  /// No description provided for @driverSupportTopicOrdersBilling.
  ///
  /// In en, this message translates to:
  /// **'Orders & Payments'**
  String get driverSupportTopicOrdersBilling;

  /// No description provided for @driverSupportTopicOrdersBillingDesc.
  ///
  /// In en, this message translates to:
  /// **'Inquiries about orders and invoices'**
  String get driverSupportTopicOrdersBillingDesc;

  /// No description provided for @driverSupportTopicAccountProfile.
  ///
  /// In en, this message translates to:
  /// **'Account & Profile'**
  String get driverSupportTopicAccountProfile;

  /// No description provided for @driverSupportTopicAccountProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Update details, change phone number'**
  String get driverSupportTopicAccountProfileDesc;

  /// No description provided for @driverSupportViewAllTopics.
  ///
  /// In en, this message translates to:
  /// **'View All Topics'**
  String get driverSupportViewAllTopics;

  /// No description provided for @driverSupportSendMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Us a Message'**
  String get driverSupportSendMessageTitle;

  /// No description provided for @driverSupportCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Category'**
  String get driverSupportCategoryLabel;

  /// No description provided for @driverSupportCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get driverSupportCategoryHint;

  /// No description provided for @driverSupportMessageDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Write the details of your issue here...'**
  String get driverSupportMessageDetailsHint;

  /// No description provided for @driverSupportAddAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment (Optional)'**
  String get driverSupportAddAttachment;

  /// No description provided for @driverSupportAttachmentHint.
  ///
  /// In en, this message translates to:
  /// **'Photos, screenshots, documents (Max 5 MB)'**
  String get driverSupportAttachmentHint;

  /// No description provided for @driverSupportSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get driverSupportSubmitButton;

  /// No description provided for @driverSupportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent to technical support successfully'**
  String get driverSupportSuccessMessage;

  /// No description provided for @driverSupportAttachmentSelected.
  ///
  /// In en, this message translates to:
  /// **'Attached: {fileName}'**
  String driverSupportAttachmentSelected(String fileName);

  /// No description provided for @sidebarStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get sidebarStatusOnline;

  /// No description provided for @sidebarHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get sidebarHome;

  /// No description provided for @sidebarOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sidebarOrders;

  /// No description provided for @sidebarMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get sidebarMap;

  /// No description provided for @sidebarAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get sidebarAnalytics;

  /// No description provided for @sidebarOperationsLog.
  ///
  /// In en, this message translates to:
  /// **'Operations Log'**
  String get sidebarOperationsLog;

  /// No description provided for @sidebarNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sidebarNotifications;

  /// No description provided for @sidebarHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get sidebarHelpSupport;

  /// No description provided for @sidebarSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sidebarSettings;

  /// No description provided for @sidebarSafetySecurity.
  ///
  /// In en, this message translates to:
  /// **'Safety & Security'**
  String get sidebarSafetySecurity;

  /// No description provided for @sidebarDriverStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Status'**
  String get sidebarDriverStatusTitle;

  /// No description provided for @sidebarDriverOffDuty.
  ///
  /// In en, this message translates to:
  /// **'Off Duty'**
  String get sidebarDriverOffDuty;

  /// No description provided for @sidebarDriverOnDuty.
  ///
  /// In en, this message translates to:
  /// **'On Duty'**
  String get sidebarDriverOnDuty;

  /// No description provided for @sidebarDriverStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available for order delivery'**
  String get sidebarDriverStatusSubtitle;

  /// No description provided for @sidebarLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get sidebarLogout;

  /// No description provided for @sidebarAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String sidebarAppVersion(String version);

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationFieldRequired;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// No description provided for @validationNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Name is not valid'**
  String get validationNameInvalid;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Email is not valid'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Password must include 8 characters, a number, uppercase letter, and symbol'**
  String get validationPasswordInvalid;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsDoNotMatch;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number is not valid'**
  String get validationPhoneInvalid;

  /// No description provided for @validationOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get validationOtpRequired;

  /// No description provided for @validationOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Verification code is invalid'**
  String get validationOtpInvalid;

  /// No description provided for @validationCivilIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Civil ID is required'**
  String get validationCivilIdRequired;

  /// No description provided for @validationCivilIdInvalid.
  ///
  /// In en, this message translates to:
  /// **'Civil ID is not valid'**
  String get validationCivilIdInvalid;
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

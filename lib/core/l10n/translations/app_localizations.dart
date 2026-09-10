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

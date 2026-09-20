import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
import 'package:meal_mate_delivery/features/account_status/domain/entities/driver_registration_status_entity.dart';
import 'package:meal_mate_delivery/features/account_status/domain/repo/account_status_repository.dart';
import 'package:meal_mate_delivery/features/account_status/domain/usecase/get_account_status_usecase.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/manager/account_status_event.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/manager/account_status_state.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/manager/account_status_view_model.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/screens/account_status_screen.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/auth_session_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/forgot_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/resend_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/set_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_application_status_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_login_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/repo/auth_repository.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/lookup_phone_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/driver_auth/domain/driver_auth_destination.dart';
import 'package:meal_mate_delivery/features/driver_auth/presentation/manager/driver_auth_coordinator.dart';

class _FakeAuthRepo implements AuthRepository {
  bool shouldFail = false;
  bool isFirstTime = true;
  PhoneLookupRequestEntity? lastLookupRequest;

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async {
    lastLookupRequest = request;
    if (shouldFail) {
      return ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'User not found or network error',
          exception: const ApiException(
            errorType: ApiErrorType.unknown,
            message: 'User not found or network error',
          ),
        ),
      );
    }
    return ApiSuccessResult(
      data: PhoneLookupResultEntity(
        role: request.role,
        phone: request.phone,
        exists: true,
        isFirstTimeSetup: isFirstTime,
        fullName: 'Test Driver',
        restaurantName: 'Balance Box',
        applicationStatus: const StaffApplicationStatusEntity(
          registrationId: 'reg-approved-1',
          stage: 4,
          isApproved: true,
        ),
      ),
    );
  }

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() async => throw UnimplementedError();
}

class _FakeStatusRepo implements AccountStatusRepository {
  AccountStatusKind returnedKind = AccountStatusKind.accepted;

  @override
  Future<ApiResult<DriverRegistrationStatusEntity>> getRegistrationStatus({
    String? phone,
    String? registrationId,
  }) async =>
      ApiSuccessResult(
        data: DriverRegistrationStatusEntity(
          registrationId: registrationId ?? 'reg-1',
          kind: returnedKind,
          phone: phone ?? '+966501234567',
          isApproved: returnedKind == AccountStatusKind.accepted,
        ),
      );
}

void main() {
  group('Approved-Account Activation and Resubmission Flow Tests', () {
    test('AccountStatusViewModel handles AccountStatusActivateApprovedEvent success', () async {
      final authRepo = _FakeAuthRepo()..isFirstTime = true;
      final statusRepo = _FakeStatusRepo();

      final viewModel = AccountStatusViewModel(
        getAccountStatusUseCase: GetAccountStatusUseCase(statusRepo),
        lookupPhoneUseCase: LookupPhoneUseCase(authRepo),
      );

      viewModel.doIntent(
        const AccountStatusActivateApprovedEvent('+966501234567'),
      );

      await Future.delayed(Duration.zero);

      expect(authRepo.lastLookupRequest?.phone, '+966501234567');
      expect(authRepo.lastLookupRequest?.role, UserRole.driver);
      expect(viewModel.state.status, AccountStatusStateStatus.activationSuccess);
      expect(viewModel.state.lookupResult, isNotNull);
      expect(viewModel.state.lookupResult?.isFirstTimeSetup, isTrue);

      // Coordinator resolves this lookup to DriverFirstTimeOtpDestination
      const coordinator = DriverAuthCoordinator();
      final destination = coordinator.resolve(viewModel.state.lookupResult!);
      expect(destination, isA<DriverFirstTimeOtpDestination>());
    });

    test('AccountStatusViewModel handles AccountStatusActivateApprovedEvent returning password login', () async {
      final authRepo = _FakeAuthRepo()..isFirstTime = false;
      final statusRepo = _FakeStatusRepo();

      final viewModel = AccountStatusViewModel(
        getAccountStatusUseCase: GetAccountStatusUseCase(statusRepo),
        lookupPhoneUseCase: LookupPhoneUseCase(authRepo),
      );

      viewModel.doIntent(
        const AccountStatusActivateApprovedEvent('+966501234567'),
      );

      await Future.delayed(Duration.zero);

      expect(viewModel.state.status, AccountStatusStateStatus.activationSuccess);
      const coordinator = DriverAuthCoordinator();
      final destination = coordinator.resolve(viewModel.state.lookupResult!);
      expect(destination, isA<DriverPasswordLoginDestination>());
    });

    test('AccountStatusViewModel handles AccountStatusActivateApprovedEvent failure', () async {
      final authRepo = _FakeAuthRepo()..shouldFail = true;
      final statusRepo = _FakeStatusRepo();

      final viewModel = AccountStatusViewModel(
        getAccountStatusUseCase: GetAccountStatusUseCase(statusRepo),
        lookupPhoneUseCase: LookupPhoneUseCase(authRepo),
      );

      viewModel.doIntent(
        const AccountStatusActivateApprovedEvent('+966501234567'),
      );

      await Future.delayed(Duration.zero);

      expect(viewModel.state.status, AccountStatusStateStatus.error);
      expect(viewModel.state.errorMessage, 'User not found or network error');
    });

    testWidgets('Approved status screen triggers activation on primary button tap and navigates to OTP', (tester) async {
      final authRepo = _FakeAuthRepo()..isFirstTime = true;
      final statusRepo = _FakeStatusRepo();

      final viewModel = AccountStatusViewModel(
        getAccountStatusUseCase: GetAccountStatusUseCase(statusRepo),
        lookupPhoneUseCase: LookupPhoneUseCase(authRepo),
      );

      String? pushedRoute;
      Object? pushedArgs;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          onGenerateRoute: (settings) {
            pushedRoute = settings.name;
            pushedArgs = settings.arguments;
            return MaterialPageRoute(builder: (_) => const SizedBox());
          },
          home: AccountStatusScreen(
            kind: AccountStatusKind.accepted,
            phone: '+966501234567',
            viewModel: viewModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find primary button ("Start work")
      final primaryButton = find.widgetWithText(AppButton, 'Start work');
      expect(primaryButton, findsOneWidget);
      await tester.tap(primaryButton);
      await tester.pumpAndSettle();

      expect(authRepo.lastLookupRequest?.phone, '+966501234567');
      expect(authRepo.lastLookupRequest?.role, UserRole.driver);
      expect(pushedRoute, AppRoutes.verifyPhoneOtp);
      expect(pushedArgs, isA<OtpVerificationRouteArgs>());
      final args = pushedArgs as OtpVerificationRouteArgs;
      expect(args.target.value, '+966501234567');
      expect(args.role, UserRole.driver);
    });

    testWidgets('NeedsChanges status screen navigates to register on primary button tap', (tester) async {
      final statusRepo = _FakeStatusRepo()
        ..returnedKind = AccountStatusKind.moreInformationRequired;
      final viewModel = AccountStatusViewModel(
        getAccountStatusUseCase: GetAccountStatusUseCase(statusRepo),
      );

      String? pushedRoute;
      Object? pushedArgs;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.register) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(builder: (_) => const SizedBox());
            }
            return MaterialPageRoute(
              builder: (_) => AccountStatusScreen(
                kind: AccountStatusKind.moreInformationRequired,
                phone: '+966501234567',
                registrationId: 'reg-changes-1',
                viewModel: viewModel,
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final primaryButton = find.widgetWithText(AppButton, 'Edit and resend');
      expect(primaryButton, findsOneWidget);
      await tester.ensureVisible(primaryButton);
      await tester.tap(primaryButton);
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.register);
      expect(pushedArgs, isA<DriverRegistrationRouteArgs>());
      final args = pushedArgs as DriverRegistrationRouteArgs;
      expect(args.isResubmission, isTrue);
      expect(args.registrationId, 'reg-changes-1');
      expect(args.phone, '+966501234567');
    });
  });
}

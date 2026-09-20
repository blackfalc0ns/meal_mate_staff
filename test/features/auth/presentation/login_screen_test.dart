import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/auth_session_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/auth_user_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/forgot_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/resend_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/set_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_login_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/repo/auth_repository.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/forgot_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/login_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/logout_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/lookup_phone_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/resend_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/restore_session_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/set_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/verify_first_time_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_view_model.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/auth_primary_button.dart';

class _FakeLoginRepo implements AuthRepository {
  ApiResult<AuthSessionEntity>? loginResult;
  ApiResult<PhoneLookupResultEntity>? lookupResult;

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async {
    return loginResult ??
        ApiSuccessResult(
          data: AuthSessionEntity(
            accessToken: 'token',
            refreshToken: 'refresh',
            user: AuthUserEntity(
              userId: 'u1',
              phoneNumber: request.phone,
              fullName: 'User',
              role: request.role,
            ),
            isAuthenticated: true,
          ),
        );
  }

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async {
    return lookupResult ??
        ApiSuccessResult(
          data: PhoneLookupResultEntity(
            exists: true,
            isFirstTimeSetup: false,
            role: request.role,
            phone: request.phone,
          ),
        );
  }

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async => ApiSuccessResult(data: 'ok');

  @override
  Future<ApiResult<void>> logout() async => ApiSuccessResult(data: null);

  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) async =>
      ApiSuccessResult(data: 'ok');

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async => ApiSuccessResult(data: 'ok');

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      ApiSuccessResult(data: null);

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async => throw UnimplementedError();
}

void main() {
  late _FakeLoginRepo fakeRepo;
  late AuthViewModel viewModel;

  setUp(() {
    fakeRepo = _FakeLoginRepo();
    viewModel = AuthViewModel(
      lookupPhoneUseCase: LookupPhoneUseCase(fakeRepo),
      verifyFirstTimeOtpUseCase: VerifyFirstTimeOtpUseCase(fakeRepo),
      setPasswordUseCase: SetPasswordUseCase(fakeRepo),
      loginUseCase: LoginUseCase(fakeRepo),
      forgotPasswordUseCase: ForgotPasswordUseCase(fakeRepo),
      resetPasswordUseCase: ResetPasswordUseCase(fakeRepo),
      resendOtpUseCase: ResendOtpUseCase(fakeRepo),
      restoreSessionUseCase: RestoreSessionUseCase(fakeRepo),
      logoutUseCase: LogoutUseCase(fakeRepo),
    );
  });

  tearDown(() {
    viewModel.close();
  });

  Widget buildTestApp(Widget screen) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      onGenerateRoute: RouteGenerator.getRoute,
      home: screen,
    );
  }

  testWidgets('LoginScreen renders phone, password, and primary button', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(LoginScreen(role: UserRole.driver, viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AuthInputField), findsNWidgets(2));
    expect(find.byType(AuthPrimaryButton), findsOneWidget);
  });

  testWidgets('LoginScreen displays InlineApiErrorWidget on error result', (
    tester,
  ) async {
    fakeRepo.loginResult = ApiErrorResult(
      failure: Failure(errorMessage: 'Invalid phone or password'),
    );

    await tester.pumpWidget(
      buildTestApp(LoginScreen(role: UserRole.driver, viewModel: viewModel)),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, '50123456');
    await tester.enterText(find.byType(TextFormField).last, 'Password123!');
    await tester.tap(find.byType(AuthPrimaryButton));
    await tester.pump();

    expect(find.byType(InlineApiErrorWidget), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(InlineApiErrorWidget),
        matching: find.text('Invalid phone or password'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'LoginScreen displays CustomProgressIndicator while loading is active',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(LoginScreen(role: UserRole.driver, viewModel: viewModel)),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, '50123456');
      await tester.enterText(find.byType(TextFormField).last, 'Password123!');
      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AuthPrimaryButton), findsOneWidget);
    },
  );
}

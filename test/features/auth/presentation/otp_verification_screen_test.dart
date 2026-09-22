import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/auth/domain/auth_verification_target.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/auth_session_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/forgot_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/resend_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/reset_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/set_password_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_login_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_role_entity.dart';
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
import 'package:meal_mate_delivery/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/otp_code_field.dart';
import 'package:pinput/pinput.dart';

class _FakeOtpRepo implements AuthRepository {
  ApiResult<VerifyFirstTimeOtpResultEntity>? verifyResult;
  ApiResult<String>? resendResult;

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async {
    return verifyResult ??
        ApiSuccessResult(
          data: VerifyFirstTimeOtpResultEntity(
            verified: true,
            verificationToken: 'vtoken',
            phone: request.phone,
            role: request.role,
            message: 'OTP verified successfully',
          ),
        );
  }

  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) async {
    return resendResult ?? ApiSuccessResult(data: 'OTP resent successfully');
  }

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      ApiSuccessResult(data: null);

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() async => ApiSuccessResult(data: null);

  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() async =>
      const ApiSuccessResult(data: []);
}

void main() {
  late _FakeOtpRepo fakeRepo;
  late AuthViewModel viewModel;

  setUp(() {
    fakeRepo = _FakeOtpRepo();
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
      home: screen,
    );
  }

  const target = AuthVerificationTarget(
    value: '+96550123456',
    imageAsset: AppAssets.authPhoneOtp,
  );

  testWidgets('OtpVerificationScreen renders OTP field and verify button', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        OtpVerificationScreen.phone(
          target: target,
          role: UserRole.driver,
          viewModel: viewModel,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    expect(find.byType(OtpCodeField), findsOneWidget);
    expect(find.byType(AuthPrimaryButton), findsOneWidget);
    expect(find.text('+96550123456'), findsOneWidget);
  });

  testWidgets(
    'OtpVerificationScreen displays InlineApiErrorWidget on error result',
    (tester) async {
      fakeRepo.verifyResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Invalid OTP code'),
      );

      await tester.pumpWidget(
        buildTestApp(
          OtpVerificationScreen.phone(
            target: target,
            role: UserRole.driver,
            viewModel: viewModel,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(Pinput), '123456');
      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();

      expect(find.byType(InlineApiErrorWidget), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(InlineApiErrorWidget),
          matching: find.text('Invalid OTP code'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'OtpVerificationScreen navigates to setPassword on successful OTP verification',
    (tester) async {
      String? pushedRoute;
      Object? pushedArgs;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.setPassword) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                builder: (_) =>
                    const Scaffold(body: Text('Set Password Screen')),
                settings: settings,
              );
            }
            return null;
          },
          home: OtpVerificationScreen.phone(
            target: target,
            role: UserRole.operations,
            viewModel: viewModel,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(Pinput), '123456');
      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.setPassword);
      expect(pushedArgs, isA<SetPasswordRouteArgs>());
      final args = pushedArgs as SetPasswordRouteArgs;
      expect(args.verificationToken, 'vtoken');
      expect(args.role, UserRole.operations);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:meal_mate_delivery/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/auth_primary_button.dart';

class _FakeForgotAndResetRepo implements AuthRepository {
  ForgotPasswordRequestEntity? lastForgotPasswordRequest;
  ResetPasswordRequestEntity? lastResetPasswordRequest;
  ResendOtpRequestEntity? lastResendOtpRequest;

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async {
    lastForgotPasswordRequest = request;
    return const ApiSuccessResult(data: 'OTP Sent Successfully');
  }

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async {
    lastResetPasswordRequest = request;
    return const ApiSuccessResult(data: 'Password Reset Successfully');
  }

  @override
  Future<ApiResult<String>> resendOtp(
    ResendOtpRequestEntity request,
  ) async {
    lastResendOtpRequest = request;
    return const ApiSuccessResult(data: 'OTP Resent');
  }

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() async => throw UnimplementedError();

  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async => throw UnimplementedError();
}

AuthViewModel _buildViewModel(_FakeForgotAndResetRepo repo) {
  return AuthViewModel(
    lookupPhoneUseCase: LookupPhoneUseCase(repo),
    verifyFirstTimeOtpUseCase: VerifyFirstTimeOtpUseCase(repo),
    loginUseCase: LoginUseCase(repo),
    forgotPasswordUseCase: ForgotPasswordUseCase(repo),
    resetPasswordUseCase: ResetPasswordUseCase(repo),
    resendOtpUseCase: ResendOtpUseCase(repo),
    setPasswordUseCase: SetPasswordUseCase(repo),
    restoreSessionUseCase: RestoreSessionUseCase(repo),
    logoutUseCase: LogoutUseCase(repo),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  group('ForgotPassword & ResetPassword Route Tests', () {
    testWidgets(
      'RouteGenerator resolves AppRoutes.forgotPassword to ForgotPasswordScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.forgotPassword,
            onGenerateInitialRoutes: (initRoute) => [
              RouteGenerator.getRoute(
                RouteSettings(
                  name: initRoute,
                  arguments: const ForgotPasswordRouteArgs(
                    role: UserRole.operations,
                    phone: '99777222',
                  ),
                ),
              ),
            ],
            onGenerateRoute: RouteGenerator.getRoute,
          ),
        );
        await tester.pump();
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );

    testWidgets(
      'RouteGenerator resolves AppRoutes.resetPassword to ResetPasswordScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.resetPassword,
            onGenerateInitialRoutes: (initRoute) => [
              RouteGenerator.getRoute(
                RouteSettings(
                  name: initRoute,
                  arguments: const ResetPasswordRouteArgs(
                    role: UserRole.operations,
                    phone: '+96599777222',
                  ),
                ),
              ),
            ],
            onGenerateRoute: RouteGenerator.getRoute,
          ),
        );
        await tester.pump();
        expect(find.byType(ResetPasswordScreen), findsOneWidget);
      },
    );
  });

  group('LoginScreen Forgot Password Navigation', () {
    testWidgets('Tapping forgot password button navigates to ForgotPasswordScreen', (
      tester,
    ) async {
      final repo = _FakeForgotAndResetRepo();
      final vm = _buildViewModel(repo);

      String? pushedRoute;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          onGenerateRoute: (settings) {
            pushedRoute = settings.name;
            if (settings.name == AppRoutes.forgotPassword) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('ForgotPasswordScreenTarget')),
              );
            }
            return RouteGenerator.getRoute(settings);
          },
          home: LoginScreen(
            role: UserRole.operations,
            viewModel: vm,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final forgotButton = find.text('نسيت كلمة المرور؟');
      expect(forgotButton, findsOneWidget);

      await tester.tap(forgotButton);
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.forgotPassword);
      expect(find.text('ForgotPasswordScreenTarget'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Tests', () {
    testWidgets('Renders phone field and submits AuthForgotPasswordEvent on tap', (
      tester,
    ) async {
      final repo = _FakeForgotAndResetRepo();
      final vm = _buildViewModel(repo);

      String? pushedRoute;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          onGenerateRoute: (settings) {
            pushedRoute = settings.name;
            if (settings.name == AppRoutes.resetPassword) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('ResetPasswordScreenTarget')),
              );
            }
            return RouteGenerator.getRoute(settings);
          },
          home: ForgotPasswordScreen(
            args: const ForgotPasswordRouteArgs(
              role: UserRole.operations,
              phone: '99777222',
            ),
            viewModel: vm,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('نسيت كلمة المرور'), findsOneWidget);
      expect(find.byType(AuthInputField), findsOneWidget);
      expect(find.byType(AuthPrimaryButton), findsOneWidget);

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pumpAndSettle();

      expect(repo.lastForgotPasswordRequest?.phone, '+96599777222');
      expect(repo.lastForgotPasswordRequest?.role, UserRole.operations);
      expect(pushedRoute, AppRoutes.resetPassword);
      expect(find.text('ResetPasswordScreenTarget'), findsOneWidget);
    });
  });

  group('ResetPasswordScreen Tests', () {
    testWidgets('Renders fields, validates and submits AuthResetPasswordEvent on tap', (
      tester,
    ) async {
      final repo = _FakeForgotAndResetRepo();
      final vm = _buildViewModel(repo);

      String? pushedRoute;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          onGenerateRoute: (settings) {
            pushedRoute = settings.name;
            if (settings.name == AppRoutes.login) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('LoginScreenTarget')),
              );
            }
            return RouteGenerator.getRoute(settings);
          },
          home: ResetPasswordScreen(
            args: const ResetPasswordRouteArgs(
              role: UserRole.operations,
              phone: '+96599777222',
            ),
            viewModel: vm,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إعادة تعيين كلمة المرور'), findsOneWidget);
      expect(find.text('+96599777222'), findsOneWidget);

      // Enter OTP
      await tester.enterText(find.byType(Pinput), '123456');

      // Enter New Password & Confirm Password
      await tester.enterText(find.byType(TextField).at(0), 'Yahya123!');
      await tester.enterText(find.byType(TextField).at(1), 'Yahya123!');
      await tester.pump();

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pumpAndSettle();

      expect(repo.lastResetPasswordRequest?.phone, '+96599777222');
      expect(repo.lastResetPasswordRequest?.role, UserRole.operations);
      expect(repo.lastResetPasswordRequest?.otpCode, '123456');
      expect(repo.lastResetPasswordRequest?.newPassword, 'Yahya123!');
      expect(pushedRoute, AppRoutes.login);
      expect(find.text('LoginScreenTarget'), findsOneWidget);
    });
  });
}


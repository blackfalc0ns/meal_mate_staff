import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
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
import 'package:meal_mate_delivery/features/auth/domain/usecase/restore_session_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepo implements AuthRepository {
  AuthSessionEntity? sessionToRestore;

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      ApiSuccessResult(data: sessionToRestore);

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
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
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() async => throw UnimplementedError();
}

void main() {
  group('Startup Auth Gate Tests', () {
    testWidgets('routes valid Driver session to driver AppShell', (
      tester,
    ) async {
      final repo = _FakeAuthRepo()
        ..sessionToRestore = const AuthSessionEntity(
          user: AuthUserEntity(
            userId: 'driver-1',
            phoneNumber: '+966501234567',
            fullName: 'Driver Name',
            role: UserRole.driver,
          ),
          accessToken: 'valid_driver_token',
          refreshToken: 'refresh_driver_token',
          isAuthenticated: true,
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
          home: SplashScreen(
            restoreSessionUseCase: RestoreSessionUseCase(repo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.appShell);
      expect(pushedArgs, isA<AppShellRouteArgs>());
      final args = pushedArgs as AppShellRouteArgs;
      expect(args.role, UserRole.driver);
    });

    testWidgets('routes valid DeliveryManager session to operations AppShell', (
      tester,
    ) async {
      final repo = _FakeAuthRepo()
        ..sessionToRestore = const AuthSessionEntity(
          user: AuthUserEntity(
            userId: 'dispatcher-1',
            phoneNumber: '+966509876543',
            fullName: 'Ops Manager',
            role: UserRole.operations,
          ),
          accessToken: 'valid_ops_token',
          refreshToken: 'refresh_ops_token',
          isAuthenticated: true,
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
          home: SplashScreen(
            restoreSessionUseCase: RestoreSessionUseCase(repo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.appShell);
      expect(pushedArgs, isA<AppShellRouteArgs>());
      final args = pushedArgs as AppShellRouteArgs;
      expect(args.role, UserRole.operations);
    });

    testWidgets(
      'routes pending driver application to AccountStatus underReview',
      (tester) async {
        final repo = _FakeAuthRepo()..sessionToRestore = null;

        SharedPreferences.setMockInitialValues({
          TokenService.userAccountStatusKey: 'Submitted',
        });
        final prefs = await SharedPreferences.getInstance();
        FlutterSecureStorage.setMockInitialValues({});
        const secureStorage = FlutterSecureStorage();
        final tokenService = TokenService(
          secureStorage: secureStorage,
          sharedPreferences: prefs,
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
            home: SplashScreen(
              restoreSessionUseCase: RestoreSessionUseCase(repo),
              tokenService: tokenService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(pushedRoute, AppRoutes.accountStatus);
        expect(pushedArgs, isA<AccountStatusRouteArgs>());
        final args = pushedArgs as AccountStatusRouteArgs;
        expect(args.kind, AccountStatusKind.underReview);
      },
    );

    testWidgets(
      'missing session shows unauthenticated role picker bottom sheet',
      (tester) async {
        final repo = _FakeAuthRepo()..sessionToRestore = null;

        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        FlutterSecureStorage.setMockInitialValues({});
        const secureStorage = FlutterSecureStorage();
        final tokenService = TokenService(
          secureStorage: secureStorage,
          sharedPreferences: prefs,
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.lightTheme,
            home: SplashScreen(
              restoreSessionUseCase: RestoreSessionUseCase(repo),
              tokenService: tokenService,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(SplashScreen));
        final locale = AppLocalizations.of(context)!;

        expect(find.text(locale.registrationChooseAccountType), findsOneWidget);
        expect(find.text(locale.registrationDriverRole), findsOneWidget);
        expect(find.text(locale.registrationOpsRole), findsOneWidget);
        expect(find.text(locale.registrationConfirm), findsOneWidget);
      },
    );
  });
}

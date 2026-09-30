import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/services/app_navigator_service.dart';
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
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_role_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_request_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/verify_first_time_otp_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/repo/auth_repository.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/forgot_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/get_staff_roles_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/login_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/logout_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/lookup_phone_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/resend_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/restore_session_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/set_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/verify_first_time_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_state.dart';
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_view_model.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/splash_screen.dart';

class _FakeTokenService implements TokenService {
  String? savedStatus;
  String? savedRole;

  @override
  String? getSavedAccountStatus() => savedStatus;

  @override
  String? getSavedRole() => savedRole;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepo implements AuthRepository {
  ApiResult<AuthSessionEntity>? loginResult;
  ApiResult<AuthSessionEntity?>? restoreResult;

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
              fullName: 'Driver',
              role: request.role,
            ),
          ),
        );
  }

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      restoreResult ?? const ApiSuccessResult(data: null);

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async =>
      ApiSuccessResult(
        data: PhoneLookupResultEntity(
          phone: request.phone,
          exists: true,
          isFirstTimeSetup: false,
          role: UserRole.driver,
        ),
      );

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async => const ApiSuccessResult(data: 'ok');

  @override
  Future<ApiResult<void>> logout() async =>
      const ApiSuccessResult(data: null);

  @override
  Future<ApiResult<String>> resendOtp(
    ResendOtpRequestEntity request,
  ) async => const ApiSuccessResult(data: 'ok');

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async => const ApiSuccessResult(data: 'ok');

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() async =>
      const ApiSuccessResult(data: []);
}

void main() {
  late _FakeTokenService fakeTokenService;
  late _FakeAuthRepo fakeAuthRepo;
  late AuthViewModel authViewModel;
  String? pushedRoute;
  Object? pushedArgs;

  setUp(() {
    fakeTokenService = _FakeTokenService();
    fakeAuthRepo = _FakeAuthRepo();

    if (GetIt.I.isRegistered<TokenService>()) {
      GetIt.I.unregister<TokenService>();
    }
    GetIt.I.registerSingleton<TokenService>(fakeTokenService);

    authViewModel = AuthViewModel(
      lookupPhoneUseCase: LookupPhoneUseCase(fakeAuthRepo),
      verifyFirstTimeOtpUseCase: VerifyFirstTimeOtpUseCase(fakeAuthRepo),
      setPasswordUseCase: SetPasswordUseCase(fakeAuthRepo),
      loginUseCase: LoginUseCase(fakeAuthRepo),
      forgotPasswordUseCase: ForgotPasswordUseCase(fakeAuthRepo),
      resetPasswordUseCase: ResetPasswordUseCase(fakeAuthRepo),
      resendOtpUseCase: ResendOtpUseCase(fakeAuthRepo),
      restoreSessionUseCase: RestoreSessionUseCase(fakeAuthRepo),
      logoutUseCase: LogoutUseCase(fakeAuthRepo),
      getStaffRolesUseCase: GetStaffRolesUseCase(fakeAuthRepo),
    );

    pushedRoute = null;
    pushedArgs = null;
  });

  tearDown(() {
    if (GetIt.I.isRegistered<TokenService>()) {
      GetIt.I.unregister<TokenService>();
    }
  });

  Widget buildLoginApp(AuthViewModel viewModel) {
    return MaterialApp(
      navigatorKey: AppNavigatorService.navigatorKey,
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      onGenerateRoute: (settings) {
        pushedRoute = settings.name;
        pushedArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SizedBox(),
        );
      },
      home: LoginScreen(role: UserRole.driver, viewModel: viewModel),
    );
  }

  Widget buildSplashApp() {
    return MaterialApp(
      navigatorKey: AppNavigatorService.navigatorKey,
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      onGenerateRoute: (settings) {
        pushedRoute = settings.name;
        pushedArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SizedBox(),
        );
      },
      home: SplashScreen(
        tokenService: fakeTokenService,
        restoreSessionUseCase: RestoreSessionUseCase(fakeAuthRepo),
      ),
    );
  }

  group('Operational Access Gating on Driver Login', () {
    testWidgets(
      'unapproved UnderReview driver is routed to accountStatus, never appShell',
      (tester) async {
        fakeTokenService.savedStatus = 'UnderReview';

        await tester.pumpWidget(buildLoginApp(authViewModel));
        await tester.pump();

        authViewModel.emit(
          const AuthState(
            status: AuthStatus.loginSuccess,
            isSuccess: true,
            session: AuthSessionEntity(
              accessToken: 'valid-token',
              refreshToken: 'refresh-token',
              user: AuthUserEntity(
                userId: 'd1',
                fullName: 'Driver 1',
                phoneNumber: '+96511111111',
                role: UserRole.driver,
                accountStatus: 'UnderReview',
              ),
            ),
          ),
        );
        await tester.pump();

        expect(pushedRoute, AppRoutes.accountStatus);
        expect(pushedArgs, isA<AccountStatusRouteArgs>());
        final args = pushedArgs as AccountStatusRouteArgs;
        expect(args.kind, AccountStatusKind.underReview);
      },
    );

    testWidgets('rejected driver is routed to accountStatus with rejected kind', (
      tester,
    ) async {
      fakeTokenService.savedStatus = 'Rejected';

      await tester.pumpWidget(buildLoginApp(authViewModel));
      await tester.pump();

      authViewModel.emit(
        const AuthState(
          status: AuthStatus.loginSuccess,
          isSuccess: true,
          session: AuthSessionEntity(
            accessToken: 'valid-token',
            refreshToken: 'refresh-token',
            user: AuthUserEntity(
              userId: 'd2',
              fullName: 'Driver 2',
              phoneNumber: '+96522222222',
              role: UserRole.driver,
              accountStatus: 'Rejected',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(pushedRoute, AppRoutes.accountStatus);
      final args = pushedArgs as AccountStatusRouteArgs;
      expect(args.kind, AccountStatusKind.rejected);
    });

    testWidgets('approved driver enters operational appShell', (tester) async {
      fakeTokenService.savedStatus = 'Approved';

      await tester.pumpWidget(buildLoginApp(authViewModel));
      await tester.pump();

      authViewModel.emit(
        const AuthState(
          status: AuthStatus.loginSuccess,
          isSuccess: true,
          session: AuthSessionEntity(
            accessToken: 'valid-token',
            refreshToken: 'refresh-token',
            user: AuthUserEntity(
              userId: 'd3',
              fullName: 'Driver 3',
              phoneNumber: '+96533333333',
              role: UserRole.driver,
              accountStatus: 'Approved',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(pushedRoute, AppRoutes.appShell);
      expect(pushedArgs, UserRole.driver);
    });
  });

  group('Operational Access Gating on Splash / App Launch', () {
    testWidgets(
      'restored driver session with UnderReview status routes to accountStatus',
      (tester) async {
        fakeTokenService.savedStatus = 'UnderReview';
        fakeAuthRepo.restoreResult = const ApiSuccessResult(
          data: AuthSessionEntity(
            accessToken: 'valid-token',
            refreshToken: 'refresh-token',
            user: AuthUserEntity(
              userId: 'd1',
              fullName: 'Driver 1',
              phoneNumber: '+96511111111',
              role: UserRole.driver,
              accountStatus: 'UnderReview',
            ),
          ),
        );

        await tester.pumpWidget(buildSplashApp());
        await tester.pump();

        expect(pushedRoute, AppRoutes.accountStatus);
        final args = pushedArgs as AccountStatusRouteArgs;
        expect(args.kind, AccountStatusKind.underReview);
      },
    );

    testWidgets('restored driver session with Approved status routes to appShell', (
      tester,
    ) async {
      fakeTokenService.savedStatus = 'Approved';
      fakeAuthRepo.restoreResult = const ApiSuccessResult(
        data: AuthSessionEntity(
          accessToken: 'valid-token',
          refreshToken: 'refresh-token',
          user: AuthUserEntity(
            userId: 'd1',
            fullName: 'Driver 1',
            phoneNumber: '+96511111111',
            role: UserRole.driver,
            accountStatus: 'Approved',
          ),
        ),
      );

      await tester.pumpWidget(buildSplashApp());
      await tester.pump();

      expect(pushedRoute, AppRoutes.appShell);
    });
  });
}

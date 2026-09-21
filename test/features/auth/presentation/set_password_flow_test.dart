import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:meal_mate_delivery/features/auth/presentation/screens/set_password_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/auth_primary_button.dart';

class _FakeSetPasswordRepo implements AuthRepository {
  ApiResult<AuthSessionEntity>? setPasswordResult;
  SetPasswordRequestEntity? lastRequest;

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async {
    lastRequest = request;
    return setPasswordResult ??
        ApiSuccessResult(
          data: AuthSessionEntity(
            accessToken: 'mock_token',
            refreshToken: 'mock_refresh',
            user: AuthUserEntity(
              userId: 'u1',
              phoneNumber: request.phone,
              fullName: 'Delivery Manager',
              role: request.role,
            ),
            isAuthenticated: true,
          ),
        );
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
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<String>> resendOtp(
    ResendOtpRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() async => throw UnimplementedError();

  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() async =>
      throw UnimplementedError();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  late _FakeSetPasswordRepo fakeRepo;
  late AuthViewModel viewModel;

  setUp(() {
    fakeRepo = _FakeSetPasswordRepo();
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

  const testArgs = SetPasswordRouteArgs(
    phone: '+96599777222',
    role: UserRole.operations,
    verificationToken: 'test_token_123',
  );

  Widget buildTestApp({
    Widget? home,
    RouteFactory? onGenerateRoute,
    String? initialRoute,
  }) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: initialRoute == null
          ? null
          : (initRoute) => [
                RouteGenerator.getRoute(
                  RouteSettings(name: initRoute, arguments: testArgs),
                ),
              ],
      onGenerateRoute: onGenerateRoute,
      home: home,
    );
  }

  group('SetPassword Route & Screen Tests', () {
    testWidgets(
      'RouteGenerator resolves AppRoutes.setPassword to SetPasswordScreen',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            initialRoute: AppRoutes.setPassword,
            onGenerateRoute: RouteGenerator.getRoute,
          ),
        );
        await tester.pump();

        expect(find.byType(SetPasswordScreen), findsOneWidget);
      },
    );

    testWidgets('Validates password fields and submits valid matching passwords', (
      tester,
    ) async {
      String? pushedRoute;
      Object? pushedArgs;

      await tester.pumpWidget(
        buildTestApp(
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.appShell) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Shell')),
                settings: settings,
              );
            }
            return null;
          },
          home: SetPasswordScreen(
            args: testArgs,
            viewModel: viewModel,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SetPasswordScreen), findsOneWidget);
      expect(find.byType(AuthInputField), findsNWidgets(2));

      // Attempt to submit empty form
      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();

      // No request made on empty
      expect(fakeRepo.lastRequest, isNull);

      // Enter valid password and confirm password
      final inputFields = find.byType(TextFormField);
      await tester.enterText(inputFields.first, 'StrongPassword123!');
      await tester.enterText(inputFields.last, 'StrongPassword123!');
      await tester.pump();

      // Tap submit
      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pumpAndSettle();

      // Request sent to use case
      expect(fakeRepo.lastRequest, isNotNull);
      expect(fakeRepo.lastRequest!.phone, '+96599777222');
      expect(fakeRepo.lastRequest!.role, UserRole.operations);
      expect(fakeRepo.lastRequest!.verificationToken, 'test_token_123');
      expect(fakeRepo.lastRequest!.newPassword, 'StrongPassword123!');
      expect(fakeRepo.lastRequest!.confirmPassword, 'StrongPassword123!');

      // Navigated to appShell
      expect(pushedRoute, AppRoutes.appShell);
      expect(pushedArgs, UserRole.operations);
    });
  });
}

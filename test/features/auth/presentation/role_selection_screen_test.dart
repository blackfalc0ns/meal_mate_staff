import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/services/app_locale_notifier.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
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
import 'package:meal_mate_delivery/features/auth/domain/usecase/get_staff_roles_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/login_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/logout_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/lookup_phone_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/resend_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/restore_session_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/set_password_usecase.dart';
import 'package:meal_mate_delivery/features/auth/domain/usecase/verify_first_time_otp_usecase.dart';
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_event.dart';
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_view_model.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/role_selection_card.dart';

class _FakeRoleSelectionRepo implements AuthRepository {
  ApiResult<List<StaffRoleEntity>> rolesResult = const ApiSuccessResult(
    data: [
      StaffRoleEntity(
        code: 'driver',
        name: 'Driver',
        nameAr: 'سائق',
        nameEn: 'Driver',
        description: 'Deliver orders fast',
        descriptionAr: 'توصيل الطلبات بسرعة',
        descriptionEn: 'Deliver orders fast',
        iconKey: 'delivery_dining',
        allowsSelfRegistration: true,
        displayOrder: 1,
      ),
      StaffRoleEntity(
        code: 'delivery_manager',
        name: 'Delivery Manager',
        nameAr: 'مسؤول توصيل',
        nameEn: 'Delivery Manager',
        description: 'Manage fleets and drivers',
        descriptionAr: 'إدارة أسطول السائقين',
        descriptionEn: 'Manage fleets and drivers',
        iconKey: 'local_shipping',
        allowsSelfRegistration: false,
        displayOrder: 2,
      ),
    ],
  );

  int getStaffRolesCallCount = 0;

  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() async {
    getStaffRolesCallCount++;
    return rolesResult;
  }

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> logout() async => throw UnimplementedError();

  @override
  Future<ApiResult<String>> resendOtp(
    ResendOtpRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async => throw UnimplementedError();

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      throw UnimplementedError();

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
  late _FakeRoleSelectionRepo fakeRepo;
  late AuthViewModel viewModel;

  setUp(() {
    fakeRepo = _FakeRoleSelectionRepo();
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
      getStaffRolesUseCase: GetStaffRolesUseCase(fakeRepo),
    );
  });

  tearDown(() {
    viewModel.close();
  });

  Widget buildTestApp(Widget screen, {NavigatorObserver? observer}) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          navigatorObservers: observer != null ? [observer] : const [],
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              settings: settings,
              builder: (ctx) {
                if (settings.name == AppRoutes.login) {
                  return const Scaffold(body: Text('Login Route Target'));
                }
                return screen;
              },
            );
          },
          home: screen,
        );
      },
    );
  }

  group('RoleSelectionScreen Tests', () {
    testWidgets('fetches roles and renders selection cards and titles', (
      tester,
    ) async {
      appLocaleNotifier.value = const Locale('ar');

      await tester.pumpWidget(
        buildTestApp(RoleSelectionScreen(viewModel: viewModel)),
      );

      // Trigger load event and wait for microtasks
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RoleSelectionCard), findsNWidgets(2));
      expect(find.text('سائق'), findsOneWidget);
      expect(find.text('مسؤول توصيل'), findsOneWidget);
      expect(find.text('تسجيل ذاتي'), findsOneWidget);
      expect(fakeRepo.getStaffRolesCallCount, 1);
    });

    testWidgets('allows selecting different role and enables continue button', (
      tester,
    ) async {
      appLocaleNotifier.value = const Locale('ar');

      await tester.pumpWidget(
        buildTestApp(RoleSelectionScreen(viewModel: viewModel)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially first role is selected
      final cards = find.byType(RoleSelectionCard);
      expect(cards, findsNWidgets(2));

      // Tap on the second card (delivery manager)
      await tester.tap(cards.at(1));
      await tester.pump();

      // Tap Continue button
      final continueBtn = find.text('متابعة');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Should have navigated to login route
      expect(find.text('Login Route Target'), findsOneWidget);
    });

    testWidgets('toggling language chip updates locale', (tester) async {
      appLocaleNotifier.value = const Locale('ar');

      await tester.pumpWidget(
        buildTestApp(RoleSelectionScreen(viewModel: viewModel)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // In Arabic, button shows English switch
      expect(find.text('English'), findsOneWidget);

      // Tap toggle chip
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // App locale changed to en
      expect(appLocaleNotifier.value.languageCode, 'en');
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('Driver'), findsWidgets);
    });

    testWidgets('shows ApiErrorWidget on failure and retries on tap', (
      tester,
    ) async {
      appLocaleNotifier.value = const Locale('ar');
      fakeRepo.rolesResult = ApiErrorResult(
        failure: ServerFailure(
          errorMessage: 'Connection lost',
          exception: const ApiException(
            errorType: ApiErrorType.noInternetConnection,
            message: 'No internet connection',
          ),
        ),
      );

      await tester.pumpWidget(
        buildTestApp(RoleSelectionScreen(viewModel: viewModel)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // ApiErrorWidget should be rendered
      expect(find.byType(ApiErrorWidget), findsOneWidget);

      // Fix repo and click retry
      fakeRepo.rolesResult = const ApiSuccessResult(
        data: [
          StaffRoleEntity(
            code: 'driver',
            name: 'Driver',
            nameAr: 'سائق',
            nameEn: 'Driver',
            description: 'Deliver',
            descriptionAr: 'توصيل',
            descriptionEn: 'Deliver',
            iconKey: 'delivery_dining',
            allowsSelfRegistration: true,
            displayOrder: 1,
          ),
        ],
      );

      // Find retry button and tap it
      final retryBtn = find.widgetWithText(AppButton, 'Retry');
      expect(retryBtn, findsOneWidget);
      await tester.tap(retryBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeRepo.getStaffRolesCallCount, greaterThanOrEqualTo(2));
    });
  });
}

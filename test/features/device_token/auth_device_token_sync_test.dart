import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/services/push_notification_coordinator.dart';
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
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_event.dart';
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_state.dart';
import 'package:meal_mate_delivery/features/auth/presentation/manager/auth_view_model.dart';
import 'package:meal_mate_delivery/features/device_token/domain/entities/device_token_sync_context.dart';

class _FakeAuthRepository implements AuthRepository {
  ApiResult<AuthSessionEntity>? loginResult;
  ApiResult<AuthSessionEntity?>? restoreSessionResult;
  bool logoutCalled = false;
  List<String> executionOrder = [];

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async {
    return loginResult!;
  }

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async {
    return restoreSessionResult!;
  }

  @override
  Future<ApiResult<void>> logout() async {
    logoutCalled = true;
    executionOrder.add('repository.logout');
    return const ApiSuccessResult(data: null);
  }

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) => throw UnimplementedError();
  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) => throw UnimplementedError();
  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) => throw UnimplementedError();
  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) => throw UnimplementedError();
  @override
  Future<ApiResult<String>> resetPassword(ResetPasswordRequestEntity request) =>
      throw UnimplementedError();
  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) =>
      throw UnimplementedError();
  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() =>
      throw UnimplementedError();
}

class _FakePushNotificationCoordinator implements PushNotificationCoordinator {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  final List<DeviceTokenSyncContext> syncedContexts = [];
  int deactivateCallCount = 0;
  bool shouldThrowOnDeactivate = false;
  final List<String> executionOrder;

  _FakePushNotificationCoordinator({required this.executionOrder});

  @override
  Future<void> updateSyncContext(DeviceTokenSyncContext context) async {
    syncedContexts.add(context);
  }

  @override
  Future<void> clearSyncContextAndDeactivate() async {
    deactivateCallCount++;
    executionOrder.add('coordinator.clearSyncContextAndDeactivate');
    if (shouldThrowOnDeactivate) {
      throw Exception('Deactivation network timeout');
    }
  }

  @override
  DeviceTokenSyncContext? get currentContext =>
      syncedContexts.isNotEmpty ? syncedContexts.last : null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> handleLocalNotificationTap(String? rawJson) async {}
}

void main() {
  late _FakeAuthRepository repository;
  late _FakePushNotificationCoordinator coordinator;
  late AuthViewModel viewModel;
  late List<String> executionOrder;

  setUp(() {
    executionOrder = [];
    repository = _FakeAuthRepository()..executionOrder = executionOrder;
    coordinator = _FakePushNotificationCoordinator(
      executionOrder: executionOrder,
    );
    viewModel = AuthViewModel(
      lookupPhoneUseCase: LookupPhoneUseCase(repository),
      verifyFirstTimeOtpUseCase: VerifyFirstTimeOtpUseCase(repository),
      setPasswordUseCase: SetPasswordUseCase(repository),
      loginUseCase: LoginUseCase(repository),
      forgotPasswordUseCase: ForgotPasswordUseCase(repository),
      resetPasswordUseCase: ResetPasswordUseCase(repository),
      resendOtpUseCase: ResendOtpUseCase(repository),
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      getStaffRolesUseCase: const GetStaffRolesUseCase(),
      pushNotificationCoordinator: coordinator,
    );
  });

  group('AuthViewModel device token synchronization', () {
    test('successful driver login syncs driverAuthenticated context', () async {
      repository.loginResult = const ApiSuccessResult(
        data: AuthSessionEntity(
          accessToken: 'driver_jwt',
          refreshToken: 'driver_refresh',
          user: AuthUserEntity(
            userId: 'driver-id-123',
            phoneNumber: '+96511111111',
            fullName: 'Driver One',
            role: UserRole.driver,
          ),
          isAuthenticated: true,
        ),
      );

      viewModel.doIntent(
        const AuthLoginEvent(
          phone: '+96511111111',
          role: UserRole.driver,
          password: 'Password123!',
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, AuthStatus.loginSuccess);
      expect(coordinator.syncedContexts.length, 1);
      final ctx = coordinator.syncedContexts.first;
      expect(ctx, isA<DriverAuthenticatedSyncContext>());
      expect((ctx as DriverAuthenticatedSyncContext).userId, 'driver-id-123');
    });

    test(
      'successful operations login syncs deliveryManagerAuthenticated context',
      () async {
        repository.loginResult = const ApiSuccessResult(
          data: AuthSessionEntity(
            accessToken: 'manager_jwt',
            refreshToken: 'manager_refresh',
            user: AuthUserEntity(
              userId: 'mgr-id-456',
              phoneNumber: '+96522222222',
              fullName: 'Manager Two',
              role: UserRole.operations,
            ),
            isAuthenticated: true,
          ),
        );

        viewModel.doIntent(
          const AuthLoginEvent(
            phone: '+96522222222',
            role: UserRole.operations,
            password: 'Password123!',
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(viewModel.state.status, AuthStatus.loginSuccess);
        expect(coordinator.syncedContexts.length, 1);
        final ctx = coordinator.syncedContexts.first;
        expect(ctx, isA<DeliveryManagerAuthenticatedSyncContext>());
        expect(
          (ctx as DeliveryManagerAuthenticatedSyncContext).userId,
          'mgr-id-456',
        );
      },
    );

    test('successful restoreSession syncs token for restored role', () async {
      repository.restoreSessionResult = const ApiSuccessResult(
        data: AuthSessionEntity(
          accessToken: 'restored_jwt',
          refreshToken: 'restored_refresh',
          user: AuthUserEntity(
            userId: 'driver-restored',
            phoneNumber: '+96533333333',
            fullName: 'Restored Driver',
            role: UserRole.driver,
          ),
          isAuthenticated: true,
        ),
      );

      viewModel.doIntent(const AuthRestoreSessionEvent());

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, AuthStatus.sessionRestored);
      expect(coordinator.syncedContexts.length, 1);
      expect(
        coordinator.syncedContexts.first,
        isA<DriverAuthenticatedSyncContext>(),
      );
    });

    test(
      'logout invokes clearSyncContextAndDeactivate before repository.logout',
      () async {
        viewModel.doIntent(const AuthLogoutEvent());

        await Future<void>.delayed(Duration.zero);

        expect(coordinator.deactivateCallCount, 1);
        expect(repository.logoutCalled, isTrue);
        expect(executionOrder, [
          'coordinator.clearSyncContextAndDeactivate',
          'repository.logout',
        ]);
        expect(viewModel.state.status, AuthStatus.unauthenticated);
      },
    );

    test(
      'logout proceeds to local session clear even if deactivation throws',
      () async {
        coordinator.shouldThrowOnDeactivate = true;

        viewModel.doIntent(const AuthLogoutEvent());

        await Future<void>.delayed(Duration.zero);

        expect(coordinator.deactivateCallCount, 1);
        expect(repository.logoutCalled, isTrue);
        expect(viewModel.state.status, AuthStatus.unauthenticated);
      },
    );
  });
}

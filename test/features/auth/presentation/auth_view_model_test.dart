import 'package:flutter_test/flutter_test.dart';
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

class _FakeAuthRepository implements AuthRepository {
  ApiResult<PhoneLookupResultEntity>? lookupResult;
  ApiResult<VerifyFirstTimeOtpResultEntity>? verifyOtpResult;
  ApiResult<AuthSessionEntity>? setPasswordResult;
  ApiResult<AuthSessionEntity>? loginResult;
  ApiResult<String>? forgotPasswordResult;
  ApiResult<String>? resetPasswordResult;
  ApiResult<String>? resendOtpResult;
  ApiResult<AuthSessionEntity?>? restoreSessionResult;
  ApiResult<List<StaffRoleEntity>>? getStaffRolesResult;
  bool logoutCalled = false;
  int lookupCallCount = 0;

  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async {
    lookupCallCount++;
    return lookupResult!;
  }

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async {
    return verifyOtpResult!;
  }

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async {
    return setPasswordResult!;
  }

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async {
    return loginResult!;
  }

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async {
    return forgotPasswordResult!;
  }

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async {
    return resetPasswordResult!;
  }

  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) async {
    return resendOtpResult!;
  }

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async {
    return restoreSessionResult!;
  }

  @override
  Future<ApiResult<void>> logout() async {
    logoutCalled = true;
    return ApiSuccessResult(data: null);
  }

  @override
  Future<ApiResult<List<StaffRoleEntity>>> getStaffRoles() async {
    return getStaffRolesResult ?? ApiSuccessResult(data: const []);
  }
}

void main() {
  late _FakeAuthRepository fakeRepo;
  late LookupPhoneUseCase lookupPhoneUseCase;
  late VerifyFirstTimeOtpUseCase verifyFirstTimeOtpUseCase;
  late SetPasswordUseCase setPasswordUseCase;
  late LoginUseCase loginUseCase;
  late ForgotPasswordUseCase forgotPasswordUseCase;
  late ResetPasswordUseCase resetPasswordUseCase;
  late ResendOtpUseCase resendOtpUseCase;
  late RestoreSessionUseCase restoreSessionUseCase;
  late LogoutUseCase logoutUseCase;
  late GetStaffRolesUseCase getStaffRolesUseCase;
  late AuthViewModel viewModel;

  setUp(() {
    fakeRepo = _FakeAuthRepository();
    lookupPhoneUseCase = LookupPhoneUseCase(fakeRepo);
    verifyFirstTimeOtpUseCase = VerifyFirstTimeOtpUseCase(fakeRepo);
    setPasswordUseCase = SetPasswordUseCase(fakeRepo);
    loginUseCase = LoginUseCase(fakeRepo);
    forgotPasswordUseCase = ForgotPasswordUseCase(fakeRepo);
    resetPasswordUseCase = ResetPasswordUseCase(fakeRepo);
    resendOtpUseCase = ResendOtpUseCase(fakeRepo);
    restoreSessionUseCase = RestoreSessionUseCase(fakeRepo);
    logoutUseCase = LogoutUseCase(fakeRepo);
    getStaffRolesUseCase = GetStaffRolesUseCase(fakeRepo);

    viewModel = AuthViewModel(
      lookupPhoneUseCase: lookupPhoneUseCase,
      verifyFirstTimeOtpUseCase: verifyFirstTimeOtpUseCase,
      setPasswordUseCase: setPasswordUseCase,
      loginUseCase: loginUseCase,
      forgotPasswordUseCase: forgotPasswordUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
      resendOtpUseCase: resendOtpUseCase,
      restoreSessionUseCase: restoreSessionUseCase,
      logoutUseCase: logoutUseCase,
      getStaffRolesUseCase: getStaffRolesUseCase,
    );
  });

  tearDown(() {
    viewModel.close();
  });

  const testUser = AuthUserEntity(
    userId: 'u1',
    phoneNumber: '+96550123456',
    fullName: 'Ahmad Staff',
    role: UserRole.driver,
  );

  const testSession = AuthSessionEntity(
    accessToken: 'token123',
    refreshToken: 'refresh123',
    user: testUser,
    isAuthenticated: true,
  );

  group('AuthViewModel Initial State & Role change', () {
    test('initial state defaults correctly', () {
      expect(viewModel.state.status, AuthStatus.initial);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.role, UserRole.operations);
    });

    test('AuthRoleChangedEvent updates role in state', () {
      viewModel.doIntent(const AuthRoleChangedEvent(UserRole.driver));
      expect(viewModel.state.role, UserRole.driver);
    });
  });

  group('AuthPhoneLookupEvent Tests', () {
    test('lookup success emits lookupSuccess with result and phone', () async {
      const lookupEntity = PhoneLookupResultEntity(
        exists: true,
        isFirstTimeSetup: true,
        role: UserRole.driver,
        phone: '+96550123456',
        fullName: 'Ahmad Driver',
      );
      fakeRepo.lookupResult = ApiSuccessResult(data: lookupEntity);

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.lookupSuccess,
      );

      viewModel.doIntent(
        const AuthPhoneLookupEvent(
          phone: '+96550123456',
          role: UserRole.driver,
        ),
      );

      final state = await future;
      expect(state.isLoading, false);
      expect(state.lookupResult, lookupEntity);
      expect(state.phone, '+96550123456');
    });

    test('lookup error preserves phone and emits error status', () async {
      fakeRepo.lookupResult = ApiErrorResult(
        failure: Failure(errorMessage: 'User not found'),
      );

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.error,
      );

      viewModel.doIntent(
        const AuthPhoneLookupEvent(
          phone: '+96550123456',
          role: UserRole.operations,
        ),
      );

      final state = await future;
      expect(state.isLoading, false);
      expect(state.phone, '+96550123456');
      expect(state.errorMessage, 'User not found');
    });

    test('prevents duplicate submit when already loading', () async {
      fakeRepo.lookupResult = ApiSuccessResult(
        data: const PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: false,
          role: UserRole.driver,
          phone: '+96550123456',
        ),
      );

      viewModel.doIntent(
        const AuthPhoneLookupEvent(
          phone: '+96550123456',
          role: UserRole.driver,
        ),
      );
      viewModel.doIntent(
        const AuthPhoneLookupEvent(
          phone: '+96550123456',
          role: UserRole.driver,
        ),
      );

      await viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.lookupSuccess,
      );
      expect(fakeRepo.lookupCallCount, 1);
    });
  });

  group('AuthLoginEvent Tests', () {
    test('login success emits loginSuccess and stores session', () async {
      fakeRepo.loginResult = ApiSuccessResult(data: testSession);

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.loginSuccess,
      );

      viewModel.doIntent(
        const AuthLoginEvent(
          phone: '+96550123456',
          role: UserRole.driver,
          password: 'Password123!',
        ),
      );

      final state = await future;
      expect(state.isLoading, false);
      expect(state.session, testSession);
    });

    test('login error preserves inputs and emits failure', () async {
      fakeRepo.loginResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Invalid credentials'),
      );

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.error,
      );

      viewModel.doIntent(
        const AuthLoginEvent(
          phone: '+96550123456',
          role: UserRole.driver,
          password: 'WrongPassword',
        ),
      );

      final state = await future;
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Invalid credentials');
    });
  });

  group('AuthVerifyFirstTimeOtpEvent Tests', () {
    test('verify OTP success emits otpVerified with token', () async {
      const otpResult = VerifyFirstTimeOtpResultEntity(
        verified: true,
        verificationToken: 'vToken123',
        phone: '+96550123456',
        role: UserRole.driver,
        message: 'Verified',
      );
      fakeRepo.verifyOtpResult = ApiSuccessResult(data: otpResult);

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.otpVerified,
      );

      viewModel.doIntent(
        const AuthVerifyFirstTimeOtpEvent(
          phone: '+96550123456',
          role: UserRole.driver,
          otpCode: '123456',
        ),
      );

      final state = await future;
      expect(state.isLoading, false);
      expect(state.otpResult, otpResult);
    });
  });

  group('AuthSetPasswordEvent Tests', () {
    test('set password success emits passwordSetSuccess and session', () async {
      fakeRepo.setPasswordResult = ApiSuccessResult(data: testSession);

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.passwordSetSuccess,
      );

      viewModel.doIntent(
        const AuthSetPasswordEvent(
          phone: '+96550123456',
          role: UserRole.driver,
          verificationToken: 'vToken123',
          newPassword: 'Password123!',
          confirmPassword: 'Password123!',
        ),
      );

      final state = await future;
      expect(state.isLoading, false);
      expect(state.session, testSession);
    });
  });

  group('AuthRestoreSessionEvent & AuthLogoutEvent Tests', () {
    test('restore session with active session emits sessionRestored', () async {
      fakeRepo.restoreSessionResult = ApiSuccessResult(data: testSession);

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.sessionRestored,
      );

      viewModel.doIntent(const AuthRestoreSessionEvent());

      final state = await future;
      expect(state.session, testSession);
    });

    test('restore session with null emits unauthenticated', () async {
      fakeRepo.restoreSessionResult = ApiSuccessResult(data: null);

      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.unauthenticated,
      );

      viewModel.doIntent(const AuthRestoreSessionEvent());

      final state = await future;
      expect(state.session, null);
    });

    test('logout calls usecase and clears session', () async {
      final future = viewModel.stream.firstWhere(
        (s) => s.status == AuthStatus.unauthenticated,
      );

      viewModel.doIntent(const AuthLogoutEvent());

      final state = await future;
      expect(fakeRepo.logoutCalled, true);
      expect(state.session, null);
    });

    test('AuthGetStaffRolesEvent fetches roles and updates state', () async {
      const mockRoles = [
        StaffRoleEntity(
          code: 'driver',
          name: 'Driver',
          nameAr: 'سائق',
          nameEn: 'Driver',
          description: 'Deliver orders',
          descriptionAr: 'توصيل الطلبات',
          descriptionEn: 'Deliver orders',
          iconKey: 'delivery_dining',
          allowsSelfRegistration: true,
          displayOrder: 1,
        ),
      ];
      fakeRepo.getStaffRolesResult = const ApiSuccessResult(data: mockRoles);

      final future = viewModel.stream.firstWhere(
        (s) => !s.isLoadingRoles && s.roles.isNotEmpty,
      );

      viewModel.doIntent(const AuthGetStaffRolesEvent());

      final state = await future;
      expect(state.roles.length, 1);
      expect(state.roles.first.code, 'driver');
      expect(state.rolesFailure, isNull);
    });
  });
}

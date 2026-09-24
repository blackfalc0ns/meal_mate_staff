import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../domain/entities/forgot_password_request_entity.dart';
import '../../domain/entities/phone_lookup_request_entity.dart';
import '../../domain/entities/resend_otp_request_entity.dart';
import '../../domain/entities/reset_password_request_entity.dart';
import '../../domain/entities/set_password_request_entity.dart';
import '../../domain/entities/staff_login_request_entity.dart';
import '../../domain/entities/verify_first_time_otp_request_entity.dart';
import '../../domain/usecase/forgot_password_usecase.dart';
import '../../domain/usecase/get_staff_roles_usecase.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../domain/usecase/lookup_phone_usecase.dart';
import '../../domain/usecase/resend_otp_usecase.dart';
import '../../domain/usecase/reset_password_usecase.dart';
import '../../domain/usecase/restore_session_usecase.dart';
import '../../domain/usecase/set_password_usecase.dart';
import '../../domain/usecase/verify_first_time_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthViewModel extends Cubit<AuthState> {
  AuthViewModel({
    required this.lookupPhoneUseCase,
    required this.verifyFirstTimeOtpUseCase,
    required this.setPasswordUseCase,
    required this.loginUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.resendOtpUseCase,
    required this.restoreSessionUseCase,
    required this.logoutUseCase,
    GetStaffRolesUseCase? getStaffRolesUseCase,
  }) : getStaffRolesUseCase =
           getStaffRolesUseCase ?? const GetStaffRolesUseCase(),
       super(const AuthState());

  final LookupPhoneUseCase lookupPhoneUseCase;
  final VerifyFirstTimeOtpUseCase verifyFirstTimeOtpUseCase;
  final SetPasswordUseCase setPasswordUseCase;
  final LoginUseCase loginUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;
  final LogoutUseCase logoutUseCase;
  final GetStaffRolesUseCase getStaffRolesUseCase;

  Timer? _countdownTimer;

  void doIntent(AuthEvent event) {
    switch (event) {
      case AuthRoleChangedEvent():
        emit(state.copyWith(role: event.role));

      case AuthPhoneLookupEvent():
        _lookupPhone(event);

      case AuthVerifyFirstTimeOtpEvent():
        _verifyFirstTimeOtp(event);

      case AuthSetPasswordEvent():
        _setPassword(event);

      case AuthLoginEvent():
        _login(event);

      case AuthForgotPasswordEvent():
        _forgotPassword(event);

      case AuthResetPasswordEvent():
        _resetPassword(event);

      case AuthResendOtpEvent():
        _resendOtp(event);

      case AuthRestoreSessionEvent():
        _restoreSession();

      case AuthLogoutEvent():
        _logout();

      case AuthClearFeedbackEvent():
        emit(state.copyWith(clearFeedback: true));

      case AuthResetStateEvent():
        _cancelTimer();
        emit(AuthState(role: state.role));

      case AuthGetStaffRolesEvent():
        _getStaffRoles();
    }
  }

  Future<void> _getStaffRoles() async {
    emit(state.copyWith(isLoadingRoles: true, clearRolesFailure: true));
    final result = await getStaffRolesUseCase();
    if (isClosed) return;
    switch (result) {
      case ApiSuccessResult(:final data):
        final sorted = List.of(data)
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        emit(
          state.copyWith(
            isLoadingRoles: false,
            roles: sorted,
            clearRolesFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isLoadingRoles: false, rolesFailure: failure));
    }
  }

  Future<void> _lookupPhone(AuthPhoneLookupEvent event) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearFeedback: true,
        phone: event.phone,
        role: event.role,
        status: AuthStatus.loading,
      ),
    );

    final request = PhoneLookupRequestEntity(
      phone: event.phone,
      role: event.role,
    );

    final result = await lookupPhoneUseCase(request);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            status: AuthStatus.lookupSuccess,
            lookupResult: result.data,
            phone: event.phone,
            role: event.role,
          ),
        );
        if (result.data.isFirstTimeSetup) {
          _startResendCountdown();
        }

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            status: AuthStatus.error,
            failure: result.failure,
            errorMessage: result.failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _verifyFirstTimeOtp(AuthVerifyFirstTimeOtpEvent event) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearFeedback: true,
        status: AuthStatus.loading,
      ),
    );

    final request = VerifyFirstTimeOtpRequestEntity(
      phone: event.phone,
      role: event.role,
      otpCode: event.otpCode,
    );

    final result = await verifyFirstTimeOtpUseCase(request);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            status: AuthStatus.otpVerified,
            otpResult: result.data,
          ),
        );

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            status: AuthStatus.error,
            failure: result.failure,
            errorMessage: result.failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _setPassword(AuthSetPasswordEvent event) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearFeedback: true,
        status: AuthStatus.loading,
      ),
    );

    final request = SetPasswordRequestEntity(
      phone: event.phone,
      role: event.role,
      verificationToken: event.verificationToken,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    final result = await setPasswordUseCase(request);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            status: AuthStatus.passwordSetSuccess,
            session: result.data,
          ),
        );

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            status: AuthStatus.error,
            failure: result.failure,
            errorMessage: result.failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _login(AuthLoginEvent event) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearFeedback: true,
        phone: event.phone,
        role: event.role,
        status: AuthStatus.loading,
      ),
    );

    final request = StaffLoginRequestEntity(
      phone: event.phone,
      role: event.role,
      password: event.password,
    );

    final result = await loginUseCase(request);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            status: AuthStatus.loginSuccess,
            session: result.data,
          ),
        );

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            status: AuthStatus.error,
            failure: result.failure,
            errorMessage: result.failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _forgotPassword(AuthForgotPasswordEvent event) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearFeedback: true,
        phone: event.phone,
        role: event.role,
        status: AuthStatus.loading,
      ),
    );

    final request = ForgotPasswordRequestEntity(
      phone: event.phone,
      role: event.role,
    );

    final result = await forgotPasswordUseCase(request);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            status: AuthStatus.forgotPasswordSuccess,
            message: result.data,
          ),
        );

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            status: AuthStatus.error,
            failure: result.failure,
            errorMessage: result.failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _resetPassword(AuthResetPasswordEvent event) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearFeedback: true,
        status: AuthStatus.loading,
      ),
    );

    final request = ResetPasswordRequestEntity(
      phone: event.phone,
      role: event.role,
      otpCode: event.otpCode,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    final result = await resetPasswordUseCase(request);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            status: AuthStatus.resetPasswordSuccess,
            message: result.data,
          ),
        );

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            status: AuthStatus.error,
            failure: result.failure,
            errorMessage: result.failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _resendOtp(AuthResendOtpEvent event) async {
    if (state.isLoading || !state.canResendOtp) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearFeedback: true,
        status: AuthStatus.loading,
      ),
    );

    final request = ResendOtpRequestEntity(
      phone: event.phone,
      role: event.role,
    );

    final result = await resendOtpUseCase(request);

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            status: AuthStatus.otpResentSuccess,
            message: result.data,
          ),
        );
        _startResendCountdown();

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            status: AuthStatus.error,
            failure: result.failure,
            errorMessage: result.failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _restoreSession() async {
    emit(state.copyWith(isLoading: true, status: AuthStatus.loading));

    final result = await restoreSessionUseCase();

    switch (result) {
      case ApiSuccessResult():
        if (result.data != null && result.data!.isAuthenticated) {
          emit(
            state.copyWith(
              isLoading: false,
              isSuccess: true,
              status: AuthStatus.sessionRestored,
              session: result.data,
              role: result.data!.role,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isLoading: false,
              status: AuthStatus.unauthenticated,
              clearSession: true,
            ),
          );
        }

      case ApiErrorResult():
        emit(
          state.copyWith(
            isLoading: false,
            status: AuthStatus.unauthenticated,
            clearSession: true,
          ),
        );
    }
  }

  Future<void> _logout() async {
    _cancelTimer();
    await logoutUseCase();
    emit(
      state.copyWith(
        isLoading: false,
        isSuccess: false,
        status: AuthStatus.unauthenticated,
        clearSession: true,
      ),
    );
  }

  void _startResendCountdown() {
    _cancelTimer();
    if (state.resendCountdown <= 0) {
      emit(
        state.copyWith(
          resendCountdown: 60,
          canResendOtp: false,
          status: AuthStatus.initial,
        ),
      );
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.resendCountdown - 1;
      if (current <= 0) {
        timer.cancel();
        emit(
          state.copyWith(
            resendCountdown: 0,
            canResendOtp: true,
            status: AuthStatus.initial,
          ),
        );
      } else {
        emit(
          state.copyWith(
            resendCountdown: current,
            canResendOtp: false,
            status: AuthStatus.initial,
          ),
        );
      }
    });
  }

  void startResendCountdown() => _startResendCountdown();

  void cancelTimer() => _cancelTimer();

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}

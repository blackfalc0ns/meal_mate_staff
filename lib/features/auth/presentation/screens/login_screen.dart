import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/di/di.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/network/api_results.dart';
import '../../../../core/widget/custom_progress_indecator.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../../../account_status/domain/account_status_kind.dart';
import '../../domain/auth_verification_target.dart';
import '../../domain/user_role.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';
import '../manager/auth_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_help_card.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/entities/forgot_password_request_entity.dart';
import '../../domain/entities/phone_lookup_request_entity.dart';
import '../../domain/entities/phone_lookup_result_entity.dart';
import '../../domain/entities/resend_otp_request_entity.dart';
import '../../domain/entities/reset_password_request_entity.dart';
import '../../domain/entities/set_password_request_entity.dart';
import '../../domain/entities/staff_login_request_entity.dart';
import '../../domain/entities/verify_first_time_otp_request_entity.dart';
import '../../domain/entities/verify_first_time_otp_result_entity.dart';
import '../../domain/repo/auth_repository.dart';
import '../../domain/usecase/forgot_password_usecase.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../domain/usecase/lookup_phone_usecase.dart';
import '../../domain/usecase/resend_otp_usecase.dart';
import '../../domain/usecase/reset_password_usecase.dart';
import '../../domain/usecase/restore_session_usecase.dart';
import '../../domain/usecase/set_password_usecase.dart';
import '../../domain/usecase/verify_first_time_otp_usecase.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_secondary_button.dart';

class _FakeLoginAuthRepo implements AuthRepository {
  @override
  Future<ApiResult<PhoneLookupResultEntity>> lookupPhone(
    PhoneLookupRequestEntity request,
  ) async =>
      ApiSuccessResult(
        data: PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: false,
          role: request.role,
          phone: request.phone,
        ),
      );

  @override
  Future<ApiResult<VerifyFirstTimeOtpResultEntity>> verifyFirstTimeOtp(
    VerifyFirstTimeOtpRequestEntity request,
  ) async =>
      ApiSuccessResult(
        data: VerifyFirstTimeOtpResultEntity(
          verified: true,
          verificationToken: 'token',
          phone: request.phone,
          role: request.role,
        ),
      );

  @override
  Future<ApiResult<AuthSessionEntity>> setPassword(
    SetPasswordRequestEntity request,
  ) async =>
      ApiSuccessResult(
        data: AuthSessionEntity(
          accessToken: 'mock_token',
          refreshToken: 'mock_refresh',
          user: AuthUserEntity(
            userId: 'user-1',
            phoneNumber: request.phone,
            fullName: 'User',
            role: request.role,
          ),
          isAuthenticated: true,
        ),
      );

  @override
  Future<ApiResult<AuthSessionEntity>> login(
    StaffLoginRequestEntity request,
  ) async =>
      ApiSuccessResult(
        data: AuthSessionEntity(
          accessToken: 'mock_token',
          refreshToken: 'mock_refresh',
          user: AuthUserEntity(
            userId: 'user-1',
            phoneNumber: request.phone,
            fullName: 'User',
            role: request.role,
          ),
          isAuthenticated: true,
        ),
      );

  @override
  Future<ApiResult<String>> forgotPassword(
    ForgotPasswordRequestEntity request,
  ) async =>
      ApiSuccessResult(data: 'Success');

  @override
  Future<ApiResult<String>> resetPassword(
    ResetPasswordRequestEntity request,
  ) async =>
      ApiSuccessResult(data: 'Success');

  @override
  Future<ApiResult<String>> resendOtp(ResendOtpRequestEntity request) async =>
      ApiSuccessResult(data: 'Success');

  @override
  Future<ApiResult<AuthSessionEntity?>> restoreSession() async =>
      ApiSuccessResult(data: null);

  @override
  Future<ApiResult<void>> logout() async => ApiSuccessResult(data: null);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.role = UserRole.operations,
    this.viewModel,
  });

  final UserRole role;
  final AuthViewModel? viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthViewModel _viewModel;
  late final bool _isInternalViewModel;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else if (getIt.isRegistered<AuthViewModel>()) {
      _viewModel = getIt<AuthViewModel>();
      _isInternalViewModel = true;
    } else {
      final fakeRepo = _FakeLoginAuthRepo();
      _viewModel = AuthViewModel(
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
      _isInternalViewModel = true;
    }

    _viewModel.doIntent(AuthRoleChangedEvent(widget.role));
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    if (_isInternalViewModel) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty && password.isEmpty) {
      _viewModel.doIntent(
        AuthLoginEvent(
          phone: '+96500000000',
          role: widget.role,
          password: 'demoPassword',
        ),
      );
      return;
    }

    final fullPhone = phone.startsWith('+') ? phone : '+965$phone';

    if (password.isNotEmpty) {
      _viewModel.doIntent(
        AuthLoginEvent(phone: fullPhone, role: widget.role, password: password),
      );
    } else {
      _viewModel.doIntent(
        AuthPhoneLookupEvent(phone: fullPhone, role: widget.role),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<AuthViewModel, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            CustomSnackbar.showError(
              context: context,
              message: state.errorMessage!,
            );
          } else if (state.status == AuthStatus.loginSuccess) {
            CustomSnackbar.showSuccess(
              context: context,
              message: locale.welcomeBack,
            );
            context.pushReplacementNamed(
              AppRoutes.appShell,
              arguments: widget.role,
            );
          } else if (state.status == AuthStatus.lookupSuccess) {
            final lookup = state.lookupResult;
            if (lookup == null) return;

            if (lookup.isFirstTimeSetup) {
              context.pushNamed(
                AppRoutes.verifyPhoneOtp,
                arguments: AuthVerificationTarget(
                  value: lookup.phone,
                  imageAsset: AppAssets.authPhoneOtp,
                ),
              );
            } else if (lookup.role == UserRole.driver &&
                lookup.applicationStatus != null) {
              final stage = lookup.applicationStatus!.stage;
              final kind = switch (stage) {
                2 => AccountStatusKind.moreInformationRequired,
                3 => AccountStatusKind.rejected,
                _ => AccountStatusKind.underReview,
              };
              context.pushNamed(AppRoutes.accountStatus, arguments: kind);
            } else {
              CustomSnackbar.showInfo(
                context: context,
                message: locale.passwordHint,
              );
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Scaffold(
                body: AuthBackground(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.screenH,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 72),
                          const AuthHeaderLogo(),
                          const SizedBox(height: 22),
                          Text(
                            locale.welcomeBack,
                            style: getSemiBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size22,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            locale.loginSubtitle,
                            style: getRegularStyle(
                              color: color.onSurfaceVariant,
                              fontSize: FontSize.size12,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 21),
                          AuthInputField(
                            label: locale.phoneLabel,
                            hint: locale.phoneHint,
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                            countryCode: '+965',
                            showCountryPicker: true,
                            controller: _phoneController,
                            enabled: !state.isLoading,
                          ),
                          const SizedBox(height: Spacing.md),
                          AuthInputField(
                            label: locale.passwordLabel,
                            hint: locale.passwordHint,
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            controller: _passwordController,
                            enabled: !state.isLoading,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: color.onSurfaceVariant,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      final phone = _phoneController.text
                                          .trim();
                                      final fullPhone = phone.startsWith('+')
                                          ? phone
                                          : (phone.isNotEmpty
                                                ? '+965$phone'
                                                : '');
                                      if (fullPhone.isNotEmpty) {
                                        _viewModel.doIntent(
                                          AuthForgotPasswordEvent(
                                            phone: fullPhone,
                                            role: widget.role,
                                          ),
                                        );
                                      } else {
                                        CustomSnackbar.showWarning(
                                          context: context,
                                          message: locale.phoneHint,
                                        );
                                      }
                                    },
                              child: Text(
                                locale.forgotPassword,
                                style: getSemiBoldStyle(
                                  color: color.onSurface,
                                  fontSize: FontSize.size11,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          if (state.failure != null) ...[
                            const SizedBox(height: Spacing.xs),
                            InlineApiErrorWidget(
                              failure: state.failure!,
                              onRetry: _submit,
                            ),
                            const SizedBox(height: Spacing.sm),
                          ],
                          const SizedBox(height: 2),
                          AuthPrimaryButton(
                            text: locale.login,
                            isLoading: state.isLoading,
                            onPressed: state.isLoading ? null : _submit,
                          ),
                          if (widget.role == UserRole.driver) ...[
                            const SizedBox(height: 15),
                            AuthDivider(text: locale.or),
                            const SizedBox(height: Spacing.sm),
                            AuthSecondaryButton(
                              text: locale.createAccount,
                              leadingIcon: Icons.person_add_alt_1_outlined,
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      context.pushNamed(
                                        AppRoutes.register,
                                        arguments: widget.role,
                                      );
                                    },
                            ),
                          ],
                          const SizedBox(height: Spacing.sm),
                          AuthHelpCard(
                            title: locale.needHelp,
                            subtitle: locale.helpSubtitle,
                            icon: Icons.headset_mic_outlined,
                          ),
                          const SizedBox(height: Spacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.scrim.withValues(alpha: 0.3),
                    child: const Center(child: CustomProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

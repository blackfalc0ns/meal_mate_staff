import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/di/di.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/custom_progress_indecator.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../../domain/auth_verification_target.dart';
import '../../domain/user_role.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';
import '../manager/auth_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/otp_code_field.dart';
import '../widgets/otp_help_card.dart';
import '../widgets/otp_timer_chip.dart';

enum OtpVerificationKind { phone, email }

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen.phone({
    super.key,
    required this.target,
    this.role = UserRole.driver,
    this.viewModel,
  }) : kind = OtpVerificationKind.phone;

  const OtpVerificationScreen.email({
    super.key,
    required this.target,
    this.role = UserRole.driver,
    this.viewModel,
  }) : kind = OtpVerificationKind.email;

  final OtpVerificationKind kind;
  final AuthVerificationTarget target;
  final UserRole role;
  final AuthViewModel? viewModel;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final AuthViewModel _viewModel;
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<AuthViewModel>();
    _viewModel.doIntent(AuthRoleChangedEvent(widget.role));
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    if (widget.viewModel == null) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _verify([String? code]) {
    final otp = (code ?? _otpController.text).trim();
    if (otp.length < 4) {
      CustomSnackbar.showWarning(
        context: context,
        message: context.localization.otpHint,
      );
      return;
    }

    _viewModel.doIntent(
      AuthVerifyFirstTimeOtpEvent(
        phone: widget.target.value,
        role: widget.role,
        otpCode: otp,
      ),
    );
  }

  void _resend() {
    _viewModel.doIntent(
      AuthResendOtpEvent(
        phone: widget.target.value,
        role: widget.role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final title = widget.kind == OtpVerificationKind.phone
        ? locale.verifyPhoneTitle
        : locale.verifyEmailTitle;
    final subtitle = widget.kind == OtpVerificationKind.phone
        ? locale.verifyPhoneSubtitle
        : locale.verifyEmailSubtitle;

    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<AuthViewModel, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            CustomSnackbar.showError(
              context: context,
              message: state.errorMessage!,
            );
          } else if (state.status == AuthStatus.otpResentSuccess) {
            CustomSnackbar.showSuccess(
              context: context,
              message: state.message ?? locale.resendIn,
            );
          } else if (state.status == AuthStatus.otpVerified) {
            CustomSnackbar.showSuccess(
              context: context,
              message: state.otpResult?.message ?? locale.verifyPhoneTitle,
            );
          }
        },
        builder: (context, state) {
          final resendLabel = state.canResendOtp
              ? locale.resendIn
              : '${locale.resendIn} (${state.resendCountdown}s)';

          return Stack(
            children: [
              Scaffold(
                body: AuthBackground(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Spacing.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: Spacing.lg),
                          const AuthHeaderLogo.compact(),
                          const SizedBox(height: Spacing.md),
                          Image.asset(
                            widget.target.imageAsset,
                            height: Spacing.xxxl * 3,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: Spacing.base),
                          Text(
                            title,
                            style: getSemiBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size18,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            subtitle,
                            style: getRegularStyle(
                              color: color.onSurfaceVariant,
                              fontSize: FontSize.size11,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Text(
                            widget.target.value,
                            style: getSemiBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.xxl),
                          Text(
                            locale.otpHint,
                            style: getRegularStyle(
                              color: color.onSurfaceVariant,
                              fontSize: FontSize.size11,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Spacing.sm),
                          OtpCodeField(
                            controller: _otpController,
                            enabled: !state.isLoading,
                            onCompleted: (code) => _verify(code),
                          ),
                          if (state.failure != null) ...[
                            const SizedBox(height: Spacing.md),
                            InlineApiErrorWidget(
                              failure: state.failure!,
                              onRetry: () => _verify(),
                            ),
                          ],
                          const SizedBox(height: Spacing.xxl),
                          AuthPrimaryButton(
                            text: locale.verifyCode,
                            isLoading: state.isLoading,
                            onPressed: state.isLoading ? null : () => _verify(),
                          ),
                          const SizedBox(height: Spacing.lg),
                          GestureDetector(
                            onTap: (state.canResendOtp && !state.isLoading)
                                ? _resend
                                : null,
                            child: Column(
                              children: [
                                Text(
                                  resendLabel,
                                  style: getRegularStyle(
                                    color: color.onSurfaceVariant,
                                    fontSize: FontSize.size11,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: Spacing.sm),
                                Center(
                                  child: OtpTimerChip(
                                    text: state.canResendOtp
                                        ? '00:00'
                                        : '00:${state.resendCountdown.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          AuthDivider(text: locale.or),
                          const SizedBox(height: Spacing.lg),
                          OtpHelpCard(
                            title: locale.getHelp,
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
                    child: const Center(
                      child: CustomProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

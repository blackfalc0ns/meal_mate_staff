import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/di/di.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';
import '../manager/auth_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/otp_code_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.args, this.viewModel});

  final ResetPasswordRouteArgs args;
  final AuthViewModel? viewModel;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final AuthViewModel _viewModel;
  late final TextEditingController _otpController;
  late final FocusNode _otpFocusNode;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<AuthViewModel>();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    if (widget.viewModel == null) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _resend() {
    _viewModel.doIntent(
      AuthResendOtpEvent(phone: widget.args.phone, role: widget.args.role),
    );
  }

  void _submit() {
    final otp = _otpController.text.trim();
    final otpError = Validations.validOtp(context, otp);
    if (otpError != null) {
      CustomSnackbar.showWarning(context: context, message: otpError);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    _viewModel.doIntent(
      AuthResetPasswordEvent(
        phone: widget.args.phone,
        role: widget.args.role,
        otpCode: otp,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final title = isAr ? 'إعادة تعيين كلمة المرور' : 'Reset Password';
    final subtitle = isAr
        ? 'أدخل رمز التحقق المرسل وكلمة المرور الجديدة'
        : 'Enter the verification code and your new password';
    final otpHint = isAr
        ? 'رمز التحقق (OTP) المكون من 6 أرقام'
        : '6-digit verification code';
    final newPasswordLabel = isAr ? 'كلمة المرور الجديدة' : 'New Password';
    final newPasswordHint = isAr
        ? 'أدخل كلمة المرور الجديدة'
        : 'Enter new password';
    final confirmPasswordLabel = isAr
        ? 'تأكيد كلمة المرور'
        : 'Confirm Password';
    final confirmPasswordHint = isAr
        ? 'أعد إدخال كلمة المرور'
        : 'Re-enter password';
    final submitButtonText = isAr
        ? 'تأكيد وتغيير كلمة المرور'
        : 'Confirm & Reset Password';

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
              message:
                  state.message ??
                  (isAr
                      ? 'تم إعادة إرسال رمز التحقق'
                      : 'Verification code resent successfully'),
            );
          } else if (state.status == AuthStatus.resetPasswordSuccess) {
            CustomSnackbar.showSuccess(
              context: context,
              message:
                  state.message ??
                  (isAr
                      ? 'تم تعيين كلمة المرور بنجاح'
                      : 'Password reset successfully'),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
              arguments: LoginRouteArgs(role: widget.args.role),
            );
          }
        },
        builder: (context, state) {
          final resendLabel = state.canResendOtp
              ? (isAr ? 'إعادة إرسال الرمز' : 'Resend Code')
              : (isAr
                    ? 'إعادة الإرسال بعد (${state.resendCountdown} ث)'
                    : 'Resend in (${state.resendCountdown}s)');

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: AuthBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            color: color.onSurface,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        const AuthHeaderLogo.compact(),
                        const SizedBox(height: Spacing.md),
                        Text(
                          title,
                          style: getSemiBoldStyle(
                            color: color.onSurface,
                            fontSize: FontSize.size20,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          subtitle,
                          style: getRegularStyle(
                            color: color.onSurfaceVariant,
                            fontSize: FontSize.size12,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          widget.args.phone,
                          style: getSemiBoldStyle(
                            color: color.primary,
                            fontSize: FontSize.size14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.lg),
                        Text(
                          otpHint,
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
                          focusNode: _otpFocusNode,
                          enabled: !state.isLoading,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Center(
                          child: TextButton(
                            onPressed: state.canResendOtp && !state.isLoading
                                ? _resend
                                : null,
                            child: Text(
                              resendLabel,
                              style: getMediumStyle(
                                color: state.canResendOtp && !state.isLoading
                                    ? color.primary
                                    : color.onSurfaceVariant,
                                fontSize: FontSize.size12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        AuthInputField(
                          label: newPasswordLabel,
                          hint: newPasswordHint,
                          icon: Icons.lock,
                          obscureText: _obscureNewPassword,
                          controller: _newPasswordController,
                          enabled: !state.isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: color.onSurfaceVariant,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          validator: (value) =>
                              Validations.validatePassword(context, value),
                        ),
                        const SizedBox(height: Spacing.md),
                        AuthInputField(
                          label: confirmPasswordLabel,
                          hint: confirmPasswordHint,
                          icon: Icons.lock,
                          obscureText: _obscureConfirmPassword,
                          controller: _confirmPasswordController,
                          enabled: !state.isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: color.onSurfaceVariant,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) =>
                              Validations.validateConfirmPassword(
                                context,
                                _newPasswordController.text,
                                value,
                              ),
                        ),
                        const SizedBox(height: Spacing.xl),
                        AuthPrimaryButton(
                          text: submitButtonText,
                          isLoading: state.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: Spacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

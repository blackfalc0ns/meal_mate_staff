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

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({
    super.key,
    required this.args,
    this.viewModel,
  });

  final SetPasswordRouteArgs args;
  final AuthViewModel? viewModel;

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  late final AuthViewModel _viewModel;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<AuthViewModel>();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    if (widget.viewModel == null) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    _viewModel.doIntent(
      AuthSetPasswordEvent(
        phone: widget.args.phone,
        role: widget.args.role,
        verificationToken: widget.args.verificationToken,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final title = isAr ? 'تعيين كلمة المرور' : 'Set Password';
    final subtitle = isAr
        ? 'يرجى تعيين كلمة مرور جديدة لحسابك للمتابعة'
        : 'Please set a new password for your account to continue';
    final newPasswordLabel = isAr ? 'كلمة المرور الجديدة' : 'New Password';
    final newPasswordHint = isAr ? 'أدخل كلمة المرور الجديدة' : 'Enter new password';
    final confirmPasswordLabel = isAr ? 'تأكيد كلمة المرور' : 'Confirm Password';
    final confirmPasswordHint = isAr ? 'أعد إدخال كلمة المرور' : 'Re-enter password';
    final submitButtonText = isAr ? 'تأكيد وحفظ' : 'Confirm & Save';

    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<AuthViewModel, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            CustomSnackbar.showError(
              context: context,
              message: state.errorMessage!,
            );
          } else if (state.status == AuthStatus.passwordSetSuccess) {
            CustomSnackbar.showSuccess(
              context: context,
              message: state.message ??
                  (isAr
                      ? 'تم تعيين كلمة المرور بنجاح'
                      : 'Password set successfully'),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.appShell,
              (route) => false,
              arguments: widget.args.role,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: AuthBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.base,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: Spacing.xxl),
                        const AuthHeaderLogo.compact(),
                        const SizedBox(height: Spacing.xl),
                        Text(
                          title,
                          style: getBoldStyle(
                            color: color.onSurface,
                            fontSize: FontSize.size22,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          subtitle,
                          style: getRegularStyle(
                            color: color.onSurfaceVariant,
                            fontSize: FontSize.size14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xl),
                        AuthInputField(
                          label: newPasswordLabel,
                          hint: newPasswordHint,
                          icon: Icons.lock_outline,
                          obscureText: _obscureNewPassword,
                          controller: _newPasswordController,
                          enabled: !state.isLoading,
                          validator: (val) =>
                              Validations.validatePassword(context, val),
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
                        ),
                        const SizedBox(height: Spacing.md),
                        AuthInputField(
                          label: confirmPasswordLabel,
                          hint: confirmPasswordHint,
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          controller: _confirmPasswordController,
                          enabled: !state.isLoading,
                          validator: (val) =>
                              Validations.validateConfirmPassword(
                            context,
                            _newPasswordController.text,
                            val,
                          ),
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
                        ),
                        const SizedBox(height: Spacing.xl),
                        AuthPrimaryButton(
                          text: submitButtonText,
                          isLoading: state.isLoading,
                          onPressed: state.isLoading ? null : _submit,
                        ),
                        const SizedBox(height: Spacing.xxl),
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

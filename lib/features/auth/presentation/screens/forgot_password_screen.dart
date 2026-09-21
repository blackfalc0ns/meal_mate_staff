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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.args,
    this.viewModel,
  });

  final ForgotPasswordRouteArgs args;
  final AuthViewModel? viewModel;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final AuthViewModel _viewModel;
  late final TextEditingController _phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<AuthViewModel>();
    final initialPhone = widget.args.phone ?? '';
    final cleanedPhone = initialPhone.startsWith('+965')
        ? initialPhone.substring(4)
        : initialPhone;
    _phoneController = TextEditingController(text: cleanedPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    if (widget.viewModel == null) {
      _viewModel.close();
    }
    super.dispose();
  }

  String _formatPhone(String rawPhone) {
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('+')) return trimmed;
    return '+965$trimmed';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fullPhone = _formatPhone(_phoneController.text);
    _viewModel.doIntent(
      AuthForgotPasswordEvent(
        phone: fullPhone,
        role: widget.args.role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final title = isAr ? 'نسيت كلمة المرور' : 'Forgot Password';
    final subtitle = isAr
        ? 'أدخل رقم جوالك المسجل وسنرسل لك رمز التحقق'
        : 'Enter your registered phone number to receive a verification code';
    final buttonText = isAr ? 'إرسال رمز التحقق' : 'Send Verification Code';

    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<AuthViewModel, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            CustomSnackbar.showError(
              context: context,
              message: state.errorMessage!,
            );
          } else if (state.status == AuthStatus.forgotPasswordSuccess) {
            final fullPhone = _formatPhone(_phoneController.text);
            CustomSnackbar.showSuccess(
              context: context,
              message: state.message ??
                  (isAr
                      ? 'تم إرسال رمز التحقق بنجاح'
                      : 'Verification code sent successfully'),
            );
            Navigator.of(context).pushNamed(
              AppRoutes.resetPassword,
              arguments: ResetPasswordRouteArgs(
                phone: fullPhone,
                role: widget.args.role,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: AuthBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.screenH,
                  ),
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
                        const SizedBox(height: Spacing.xl),
                        const AuthHeaderLogo(),
                        const SizedBox(height: Spacing.lg),
                        Text(
                          title,
                          style: getSemiBoldStyle(
                            color: color.onSurface,
                            fontSize: FontSize.size22,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          subtitle,
                          style: getRegularStyle(
                            color: color.onSurfaceVariant,
                            fontSize: FontSize.size12,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.xxl),
                        AuthInputField(
                          label: locale.phoneLabel,
                          hint: locale.phoneHint,
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                          countryCode: '+965',
                          showCountryPicker: true,
                          controller: _phoneController,
                          enabled: !state.isLoading,
                          validator: (value) =>
                              Validations.validatePhoneNumber(context, value),
                        ),
                        const SizedBox(height: Spacing.xl),
                        AuthPrimaryButton(
                          text: buttonText,
                          isLoading: state.isLoading,
                          onPressed: _submit,
                        ),
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

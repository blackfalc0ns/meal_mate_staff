import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/routing/arguments/auth_route_arguments.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/di/di.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../../core/widget/custom_progress_indecator.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../../../dispatcher_auth/domain/dispatcher_auth_destination.dart';
import '../../../dispatcher_auth/presentation/manager/dispatcher_auth_coordinator.dart';
import '../../../driver_auth/domain/driver_auth_destination.dart';
import '../../../driver_auth/presentation/manager/driver_auth_coordinator.dart';
import '../../domain/user_role.dart';
import '../manager/auth_event.dart';
import '../manager/auth_state.dart';
import '../manager/auth_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_help_card.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.role = UserRole.driver, this.viewModel});

  final UserRole role;
  final AuthViewModel? viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthViewModel _viewModel;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<AuthViewModel>();
    _viewModel.doIntent(AuthRoleChangedEvent(widget.role));
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    if (widget.viewModel == null) {
      _viewModel.close();
    }
    super.dispose();
  }

  void _submit() {
    context.pushReplacementNamed(
      AppRoutes.appShell,
      arguments: widget.role,
    );
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

            if (widget.role == UserRole.operations) {
              const coordinator = DispatcherAuthCoordinator();
              final destination = coordinator.resolve(lookup);
              if (destination is DispatcherPasswordLoginDestination) {
                CustomSnackbar.showInfo(
                  context: context,
                  message: locale.passwordHint,
                );
              } else {
                coordinator.navigate(context, destination);
              }
            } else {
              const coordinator = DriverAuthCoordinator();
              final destination = coordinator.resolve(lookup);
              if (destination is DriverPasswordLoginDestination) {
                CustomSnackbar.showInfo(
                  context: context,
                  message: locale.passwordHint,
                );
              } else {
                coordinator.navigate(context, destination);
              }
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
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.forgotPassword,
                                        arguments: ForgotPasswordRouteArgs(
                                          role: widget.role,
                                          phone: phone.isNotEmpty
                                              ? phone
                                              : null,
                                        ),
                                      );
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
                              onPressed:
                                  // state.isLoading
                                  //     ? null
                                  //     :
                                  () {
                                    context.pushReplacementNamed(
                                      AppRoutes.appShell,
                                      arguments: widget.role,
                                    );
                                    // context.pushNamed(
                                    //   AppRoutes.register,
                                    //   arguments: widget.role,
                                    // );
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

import 'package:flutter/material.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_help_card.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_secondary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
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
                ),
                const SizedBox(height: Spacing.md),
                AuthInputField(
                  label: locale.passwordLabel,
                  hint: locale.passwordHint,
                  icon: Icons.lock,
                  obscureText: true,
                  suffixIcon: Icon(
                    Icons.visibility_outlined,
                    color: color.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () {},
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
                const SizedBox(height: 2),
                AuthPrimaryButton(
                  text: locale.login,
                  onPressed: () {
                    context.pushNamed(AppRoutes.verifyPhoneOtp);
                  },
                ),
                const SizedBox(height: 15),
                AuthDivider(text: locale.or),
                const SizedBox(height: 15),
                AuthSecondaryButton(
                  text: locale.loginWithOtp,
                  leadingIcon: Icons.chat_bubble_outline,
                  onPressed: () {
                    context.pushNamed(AppRoutes.verifyPhoneOtp);
                  },
                ),
                const SizedBox(height: Spacing.sm),
                AuthSecondaryButton(
                  text: locale.createAccount,
                  leadingIcon: Icons.person_add_alt_1_outlined,
                  onPressed: () {
                    context.pushNamed(AppRoutes.register);
                  },
                ),
                const SizedBox(height: Spacing.sm),
                AuthHelpCard(
                  title: locale.needHelp,
                  subtitle: locale.helpSubtitle,
                  icon: Icons.headset_mic_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

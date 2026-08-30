import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/auth_verification_target.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/otp_code_field.dart';
import '../widgets/otp_help_card.dart';
import '../widgets/otp_timer_chip.dart';

enum OtpVerificationKind { phone, email }

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen.phone({super.key, required this.target})
    : kind = OtpVerificationKind.phone;

  const OtpVerificationScreen.email({super.key, required this.target})
    : kind = OtpVerificationKind.email;

  final OtpVerificationKind kind;
  final AuthVerificationTarget target;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final title = kind == OtpVerificationKind.phone
        ? locale.verifyPhoneTitle
        : locale.verifyEmailTitle;
    final subtitle = kind == OtpVerificationKind.phone
        ? locale.verifyPhoneSubtitle
        : locale.verifyEmailSubtitle;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.lg),
                const AuthHeaderLogo.compact(),
                const SizedBox(height: Spacing.md),
                Image.asset(
                  target.imageAsset,
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
                  target.value,
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
                const OtpCodeField(),
                const SizedBox(height: Spacing.xxl),
                AuthPrimaryButton(text: locale.verifyCode, onPressed: () {}),
                const SizedBox(height: Spacing.lg),
                Text(
                  locale.resendIn,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.sm),
                Center(child: OtpTimerChip(text: locale.otpTimer)),
                const SizedBox(height: Spacing.lg),
                AuthDivider(text: locale.or),
                const SizedBox(height: Spacing.lg),
                OtpHelpCard(
                  title: locale.getHelp,
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

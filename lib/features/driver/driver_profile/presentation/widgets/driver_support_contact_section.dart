import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import 'driver_support_contact_card.dart';

class DriverSupportContactSection extends StatelessWidget {
  const DriverSupportContactSection({
    super.key,
    this.onCallTap,
    this.onEmailTap,
  });

  final VoidCallback? onCallTap;
  final VoidCallback? onEmailTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locale.driverSupportContactMethodsTitle,
          style: getBoldStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size16,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            DriverSupportContactCard(
              icon: Icons.phone_rounded,
              title: locale.driverSupportCallUs,
              value: locale.driverSupportPhoneNumber,
              subtitle: locale.driverSupportCallHours,
              onTap: onCallTap,
            ),
            const SizedBox(width: Spacing.md),
            DriverSupportContactCard(
              icon: Icons.mail_outline_rounded,
              title: locale.driverSupportEmail,
              value: locale.driverSupportEmailAddress,
              subtitle: locale.driverSupportEmailTurnaround,
              onTap: onEmailTap,
            ),
          ],
        ),
      ],
    );
  }
}

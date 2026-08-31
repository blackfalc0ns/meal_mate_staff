import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/widgets/auth_header_logo.dart';

class AccountStatusHeader extends StatelessWidget {
  const AccountStatusHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      children: [
        const AuthHeaderLogo.compact(),
        const SizedBox(height: Spacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_rounded,
              color: color.primary,
              size: Spacing.iconMd,
            ),
            const SizedBox(width: Spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getSemiBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size18,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle,
                  style: getRegularStyle(
                    color: color.accountStatusMutedText,
                    fontSize: FontSize.size9,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

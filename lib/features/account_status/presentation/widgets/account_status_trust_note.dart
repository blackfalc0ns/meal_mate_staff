import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';

class AccountStatusTrustNote extends StatelessWidget {
  const AccountStatusTrustNote({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.accountStatusTrustSurface,
        border: Border.all(color: color.accountStatusTrustBorder),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: SizedBox(
        height: Spacing.accountStatusTrustNoteHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: color.primary,
                size: Spacing.iconLg,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  locale.accountStatusTrustNote,
                  style: getSemiBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size8,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherProfileLogoutButton extends StatelessWidget {
  const DispatcherProfileLogoutButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.buttonRadius),
      child: Container(
        height: Spacing.buttonSmallHeight,
        decoration: BoxDecoration(
          color: color.errorContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(Spacing.buttonRadius),
          border: Border.all(
            color: color.error.withValues(alpha: 0.4),
            width: Spacing.border,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: color.error,
              size: Spacing.iconSm,
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              locale.profileLogout,
              style: getBoldStyle(
                fontSize: FontSize.size13,
                color: color.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../extensions/extensions.dart';

/// Outlined logout button displayed at the bottom of the sidebar.
class SidebarLogoutButton extends StatelessWidget {
  const SidebarLogoutButton({super.key, this.onLogout});

  final VoidCallback? onLogout;

  static const double _buttonHeight = 40.0;
  static const double _buttonRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Material(
        color: color.surface,
        borderRadius: BorderRadius.circular(_buttonRadius),
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(_buttonRadius),
          child: Container(
            height: _buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_buttonRadius),
              border: Border.all(color: color.primary, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: color.primary,
                  size: Spacing.lg,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  locale.sidebarLogout,
                  style: getBoldStyle(fontSize: 12, color: color.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

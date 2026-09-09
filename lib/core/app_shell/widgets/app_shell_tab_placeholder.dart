import 'package:flutter/material.dart';

import '../../../config/theme/font_manager.dart';
import '../../../config/theme/spacing.dart';
import '../../../config/theme/styles_manager.dart';
import '../../extensions/extensions.dart';

class AppShellTabPlaceholder extends StatelessWidget {
  const AppShellTabPlaceholder({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Spacing.iconLg,
            color: color.onSurfaceVariant,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            label,
            style: getMediumStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size14,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverNotificationsSectionHeader extends StatelessWidget {
  const DriverNotificationsSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Text(
        title,
        style: getBoldStyle(
          color: color.onSurfaceVariant,
          fontSize: FontSize.size12,
        ),
      ),
    );
  }
}

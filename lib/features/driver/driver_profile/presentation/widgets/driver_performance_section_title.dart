import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformanceSectionTitle extends StatelessWidget {
  const DriverPerformanceSectionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: Spacing.xs,
        bottom: Spacing.xs,
      ),
      child: Text(
        locale.driverPerformanceOverview,
        style: getBoldStyle(
          fontSize: FontSize.size15,
          color: color.onSurface,
        ),
      ),
    );
  }
}

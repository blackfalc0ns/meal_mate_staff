import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../orders/presentation/widgets/driver_boxes_header_logo.dart';

class DriverBoxesReceivedHeader extends StatelessWidget {
  const DriverBoxesReceivedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DriverBoxesHeaderLogo(),
        const SizedBox(height: Spacing.md),
        Text(
          locale.driverBoxesReceivedTitle,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.driverBoxesReceivedSubtitle,
          style: getRegularStyle(
            color: color.onSurfaceVariant,
            fontSize: FontSize.size12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

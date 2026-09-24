import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class StartRouteTitleSection extends StatelessWidget {
  const StartRouteTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          locale.driverStartDeliveryRouteReadyTitle,
          style: getSemiBoldStyle(
            fontSize: FontSize.size18,
            color: color.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          locale.driverStartDeliveryRouteHeadToCustomerSubtitle,
          style: getRegularStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

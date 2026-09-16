import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxStatusPill extends StatelessWidget {
  const DriverBoxStatusPill({
    super.key,
    required this.isLoaded,
  });

  final bool isLoaded;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs + 2,
        vertical: Spacing.hairline * 4,
      ),
      decoration: BoxDecoration(
        color: isLoaded ? color.tertiaryContainer : color.primaryContainer,
        borderRadius: BorderRadius.circular(Spacing.radiusXs),
      ),
      child: Text(
        isLoaded ? locale.driverStatusLoaded : locale.driverStatusNotLoaded,
        style: getRegularStyle(
          color: isLoaded ? color.tertiary : color.primary,
          fontSize: FontSize.size8,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

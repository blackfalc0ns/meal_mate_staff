import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_status.dart';

class DispatcherDriversStatusBadge extends StatelessWidget {
  const DispatcherDriversStatusBadge({
    super.key,
    required this.status,
  });

  final DispatcherDriverStatus status;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case DispatcherDriverStatus.available:
        bgColor = color.tertiaryContainer;
        textColor = color.tertiary;
        label = locale.driversStatusAvailable;
      case DispatcherDriverStatus.onTheWay:
        bgColor = color.secondaryContainer;
        textColor = color.secondary;
        label = locale.driversStatusOnTheWay;
      case DispatcherDriverStatus.onBreak:
        bgColor = color.dispatcherBadgeNormalSurface;
        textColor = color.dispatcherBadgeNormal;
        label = locale.driversStatusOnBreak;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.dispatcherBadgeHorizontal,
        vertical: Spacing.border,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Text(
        label,
        style: getMediumStyle(
          fontSize: FontSize.size10,
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

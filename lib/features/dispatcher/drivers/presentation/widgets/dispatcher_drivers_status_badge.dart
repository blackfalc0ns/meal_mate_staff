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
      height: Spacing.dispatcherDriverBadgeHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.dispatcherBadgeHorizontal,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Spacing.registrationReviewCardRadius),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Spacing.accountStatusReasonBullet,
              height: Spacing.accountStatusReasonBullet,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              label,
              style: getBoldStyle(
                fontSize: FontSize.size10,
                color: textColor,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

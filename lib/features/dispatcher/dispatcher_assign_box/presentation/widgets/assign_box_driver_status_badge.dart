import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_driver_status_type.dart';

class AssignBoxDriverStatusBadge extends StatelessWidget {
  const AssignBoxDriverStatusBadge({
    super.key,
    required this.statusType,
    required this.statusText,
  });

  final AssignBoxDriverStatusType statusType;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final Color surfaceColor;
    final Color textColor;

    switch (statusType) {
      case AssignBoxDriverStatusType.available:
        surfaceColor = color.dispatcherBadgeNewSurface;
        textColor = color.dispatcherBadgeNew;
      case AssignBoxDriverStatusType.busy:
        surfaceColor = color.dispatcherBadgeHighSurface;
        textColor = color.dispatcherBadgeHigh;
      case AssignBoxDriverStatusType.inDelivery:
        surfaceColor = color.infoSurface;
        textColor = color.info;
      case AssignBoxDriverStatusType.returning:
        surfaceColor = color.dispatcherSuggestionSurface;
        textColor = color.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm - Spacing.border,
        vertical: Spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Text(
        statusText,
        style: getSemiBoldStyle(
          color: textColor,
          fontSize: FontSize.size9,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';

class DispatcherDriversStatusBadge extends StatelessWidget {
  const DispatcherDriversStatusBadge({super.key, required this.status});

  final DispatcherDriverStatusType status;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final Color dotColor;
    final String label;

    switch (status) {
      case DispatcherDriverStatusType.available:
        dotColor = color.success;
        label = locale.driversStatusBadgeAvailable;
      case DispatcherDriverStatusType.inDelivery:
        dotColor = color.primary;
        label = locale.driversStatusBadgeInDelivery;
      case DispatcherDriverStatusType.unavailable:
        dotColor = color.error;
        label = locale.driversStatusBadgeUnavailable;
      case DispatcherDriverStatusType.unknown:
        dotColor = color.onSurfaceVariant;
        label = locale.driversStatusBadgeUnknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.4),
          width: Spacing.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.xs + Spacing.border,
            height: Spacing.xs + Spacing.border,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            label,
            style: getMediumStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size9,
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

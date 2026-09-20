import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../extensions/extensions.dart';

/// Pill-shaped status indicator showing whether the user is online.
class SidebarUserStatusChip extends StatelessWidget {
  const SidebarUserStatusChip({
    super.key,
    required this.isOnline,
    this.label,
  });

  final bool isOnline;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final effectiveLabel = label ?? (isOnline ? locale.sidebarStatusOnline : '');
    final statusColor = isOnline ? color.tertiary : color.onSurfaceVariant;
    final statusBgColor = isOnline ? color.tertiaryContainer : color.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.sm,
            height: Spacing.sm,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            effectiveLabel,
            style: getRegularStyle(
              fontSize: 10,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

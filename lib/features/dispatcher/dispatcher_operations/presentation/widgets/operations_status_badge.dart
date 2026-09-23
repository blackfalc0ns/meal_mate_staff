import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/operation_status.dart';

class OperationsStatusBadge extends StatelessWidget {
  const OperationsStatusBadge({
    super.key,
    required this.status,
    required this.timestamp,
  });

  final OperationStatus status;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final (String label, Color badgeColor, IconData icon) = switch (status) {
      OperationStatus.completed => (
        locale.operationsTabCompleted,
        color.primary,
        Icons.check_circle_outline_rounded,
      ),
      OperationStatus.reassigned => (
        locale.operationsTabReassigned,
        color.tertiary,
        Icons.autorenew_rounded,
      ),
      OperationStatus.failed => (
        locale.operationsTabFailed,
        color.error,
        Icons.error_outline_rounded,
      ),
      OperationStatus.cancelled => (
        locale.operationsTabCancelled,
        color.onSurfaceVariant,
        Icons.cancel_outlined,
      ),
      _ => (
        locale.operationsTabAll,
        color.onSurfaceVariant,
        Icons.info_outline_rounded,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: badgeColor),
              const SizedBox(width: Spacing.xs / 2),
              Text(
                label,
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size9,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xs / 2),
        Text(
          timestamp,
          style: getRegularStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size8,
            color: color.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_status.dart';

class DispatcherDriversAvatarWithStatus extends StatelessWidget {
  const DispatcherDriversAvatarWithStatus({
    super.key,
    required this.status,
    this.avatarUrl,
  });

  final DispatcherDriverStatus status;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final Color statusColor;
    switch (status) {
      case DispatcherDriverStatus.available:
        statusColor = color.tertiary;
      case DispatcherDriverStatus.onTheWay:
        statusColor = color.secondary;
      case DispatcherDriverStatus.onBreak:
        statusColor = color.outline;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: Spacing.lg,
          backgroundColor: color.primaryContainer,
          child: Icon(
            Icons.person_rounded,
            size: Spacing.iconMd - Spacing.border - Spacing.border,
            color: color.primary,
          ),
        ),
        PositionedDirectional(
          bottom: Spacing.zero,
          end: Spacing.zero,
          child: Container(
            width: Spacing.sm + Spacing.border + Spacing.border,
            height: Spacing.sm + Spacing.border + Spacing.border,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.surface,
                width: Spacing.border + Spacing.hairline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

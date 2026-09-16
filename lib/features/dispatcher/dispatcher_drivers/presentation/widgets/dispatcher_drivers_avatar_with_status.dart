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

    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return SizedBox(
      width: Spacing.dispatcherDriverAvatarSize,
      height: Spacing.dispatcherDriverAvatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: Spacing.dispatcherDriverAvatarSize,
            height: Spacing.dispatcherDriverAvatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.primaryContainer,
            ),
            child: ClipOval(
              child: hasAvatar
                  ? (avatarUrl!.startsWith('http')
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          width: Spacing.dispatcherDriverAvatarSize,
                          height: Spacing.dispatcherDriverAvatarSize,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_rounded,
                            size: Spacing.iconMd,
                            color: color.primary,
                          ),
                        )
                      : Image.asset(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          width: Spacing.dispatcherDriverAvatarSize,
                          height: Spacing.dispatcherDriverAvatarSize,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_rounded,
                            size: Spacing.iconMd,
                            color: color.primary,
                          ),
                        ))
                  : Icon(
                      Icons.person_rounded,
                      size: Spacing.iconMd,
                      color: color.primary,
                    ),
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
      ),
    );
  }
}

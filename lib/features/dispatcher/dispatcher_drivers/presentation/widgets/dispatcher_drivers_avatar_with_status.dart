import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../domain/entities/dispatcher_driver_status.dart';

class DispatcherDriversAvatarWithStatus extends StatelessWidget {
  const DispatcherDriversAvatarWithStatus({
    super.key,
    required this.status,
    this.statusDotColor,
    this.avatarUrl,
  });

  final DispatcherDriverStatus status;
  final String? statusDotColor;
  final String? avatarUrl;

  Color _resolveStatusColor(ColorScheme color) {
    if (statusDotColor != null && statusDotColor!.isNotEmpty) {
      final hex = statusDotColor!.replaceFirst('#', '');
      if (hex.length == 6) {
        final parsed = int.tryParse('FF$hex', radix: 16);
        if (parsed != null) return Color(parsed);
      }
    }
    switch (status) {
      case DispatcherDriverStatus.available:
        return color.tertiary;
      case DispatcherDriverStatus.busy:
      case DispatcherDriverStatus.onTheWay:
        return color.secondary;
      case DispatcherDriverStatus.onBreak:
        return color.outline;
      case DispatcherDriverStatus.unknown:
        return color.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final statusColor = _resolveStatusColor(color);

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
            child: AppCachedNetworkImage(
              imageUrl: avatarUrl,
              width: Spacing.dispatcherDriverAvatarSize,
              height: Spacing.dispatcherDriverAvatarSize,
              shape: BoxShape.circle,
              fit: BoxFit.cover,
              errorWidget: Icon(
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

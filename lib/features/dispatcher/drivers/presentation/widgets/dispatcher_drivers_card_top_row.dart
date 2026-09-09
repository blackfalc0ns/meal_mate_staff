import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import 'dispatcher_drivers_avatar_with_status.dart';
import 'dispatcher_drivers_card_action_button.dart';
import 'dispatcher_drivers_status_badge.dart';

class DispatcherDriversCardTopRow extends StatelessWidget {
  const DispatcherDriversCardTopRow({
    super.key,
    required this.driver,
    this.onSelect,
  });

  final DispatcherDriverEntity driver;
  final ValueChanged<DispatcherDriverEntity>? onSelect;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      children: [
        DispatcherDriversAvatarWithStatus(
          status: driver.status,
          avatarUrl: driver.avatarUrl,
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      driver.name,
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.star_rounded,
                    size: Spacing.iconXs,
                    color: color.secondary,
                  ),
                  const SizedBox(width: Spacing.border + Spacing.border),
                  Text(
                    driver.rating.toStringAsFixed(1),
                    style: getMediumStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.border + Spacing.border),
              Row(
                children: [
                  Text(
                    'ID:${driver.id}',
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: DispatcherDriversStatusBadge(status: driver.status),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xs),
        DispatcherDriversCardActionButton(
          isAvailable: driver.isAvailable,
          onTap: driver.isAvailable ? () => onSelect?.call(driver) : null,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            driver.name,
                            style: getBoldStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurface,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            driver.rating.toStringAsFixed(1),
                            style: getBoldStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurface,
                            ),
                          ),
                          const SizedBox(width: Spacing.border),
                          Icon(
                            Icons.star_rounded,
                            size:
                                Spacing.iconXs -
                                Spacing.border -
                                Spacing.border,
                            color: color.secondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      'ID:${driver.id}',
                      style: getBoldStyle(
                        fontSize: FontSize.size9,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              DispatcherDriversStatusBadge(status: driver.status),
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

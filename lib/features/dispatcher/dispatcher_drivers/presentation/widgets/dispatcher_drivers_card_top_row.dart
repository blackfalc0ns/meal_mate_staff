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
    this.isLoading = false,
    this.isDisabled = false,
    this.actionLabel,
    this.onSelect,
  });

  final DispatcherDriverEntity driver;
  final bool isLoading;
  final bool isDisabled;
  final String? actionLabel;
  final ValueChanged<DispatcherDriverEntity>? onSelect;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final codeText = driver.driverCode.isNotEmpty
        ? driver.driverCode
        : 'ID:${driver.driverId}';

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
                            driver.fullName.isNotEmpty
                                ? driver.fullName
                                : driver.name,
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
                      codeText,
                      style: getBoldStyle(
                        fontSize: FontSize.size9,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              DispatcherDriversStatusBadge(
                status: driver.status,
                statusText: driver.statusText,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xs),
        DispatcherDriversCardActionButton(
          isAvailable: driver.isAvailableForSelection,
          isLoading: isLoading,
          isDisabled: isDisabled,
          label: actionLabel,
          onTap: driver.isAvailableForSelection
              ? () => onSelect?.call(driver)
              : null,
        ),
      ],
    );
  }
}

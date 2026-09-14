import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'driver_filter_card_frame.dart';

class DriverFilterStatusSection extends StatelessWidget {
  const DriverFilterStatusSection({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final String? selectedStatus;
  final ValueChanged<String?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final statuses = [
      (key: null, label: locale.driverFilterAllStatuses, dotColor: null),
      (
        key: 'available',
        label: locale.driverFilterStatusAvailable,
        dotColor: color.tertiary,
      ),
      (
        key: 'busy',
        label: locale.driverFilterStatusBusyNow,
        dotColor: color.secondary,
      ),
      (
        key: 'on_the_way',
        label: locale.driverFilterStatusOnWay,
        dotColor: color.secondaryContainer,
      ),
      (
        key: 'unavailable',
        label: locale.driverFilterStatusUnavailable,
        dotColor: color.onSurfaceVariant,
      ),
    ];

    return DriverFilterCardFrame(
      title: locale.driverFilterByStatus,
      icon: Icon(
        Icons.person_rounded,
        size: Spacing.iconSm,
        color: color.primary,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((status) {
            final isSelected = selectedStatus == status.key;

            final borderColor = color.outline.withValues(alpha: 0.5);

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: Spacing.xs + 2),
              child: InkWell(
                onTap: () => onStatusSelected(status.key),
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color.primary : color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    border: isSelected
                        ? null
                        : Border.all(color: borderColor, width: Spacing.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status.dotColor != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.onPrimary
                                : status.dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                      ],
                      Text(
                        status.label,
                        style: isSelected
                            ? getBoldStyle(
                                color: color.onPrimary,
                                fontSize: FontSize.size11,
                              )
                            : getRegularStyle(
                                color: color.onSurfaceVariant,
                                fontSize: FontSize.size11,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

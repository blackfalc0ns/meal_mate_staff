import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'driver_filter_card_frame.dart';

class DriverFilterDistanceSection extends StatelessWidget {
  const DriverFilterDistanceSection({
    super.key,
    required this.distanceKm,
    required this.onDistanceChanged,
  });

  final double? distanceKm;
  final ValueChanged<double?> onDistanceChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final currentVal = (distanceKm ?? 50.0).clamp(0.0, 50.0);

    final distanceChips = [
      (key: null, label: locale.driverFilterAllStatuses),
      (key: 5.0, label: locale.driverFilterDistanceRange5),
      (key: 10.0, label: locale.driverFilterDistanceRange10),
      (key: 20.0, label: locale.driverFilterDistanceRange20),
      (key: 50.0, label: locale.driverFilterDistanceRange50),
      (key: 50.0, label: locale.driverFilterDistance50PlusKm),
    ];

    return DriverFilterCardFrame(
      title: locale.driverFilterByDistance,
      icon: Icon(
        Icons.directions_car_rounded,
        size: Spacing.iconSm,
        color: color.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider with end labels
          Row(
            children: [
              Text(
                locale.driverFilterDistance0Km,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size11,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color.primary,
                    inactiveTrackColor: color.outlineVariant,
                    thumbColor: color.primary,
                    overlayColor: color.primary.withValues(alpha: 0.1),
                    trackHeight: Spacing.xs / 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: Spacing.xs + Spacing.border * 2,
                    ),
                  ),
                  child: Slider(
                    value: currentVal,
                    min: 0.0,
                    max: 50.0,
                    onChanged: (val) => onDistanceChanged(val),
                  ),
                ),
              ),
              Text(
                locale.driverFilterDistance50PlusKm,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),

          // Quick Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: distanceChips.map((chip) {
                final isSelected = chip.key == null
                    ? distanceKm == null
                    : (distanceKm != null &&
                          (distanceKm! - chip.key!).abs() < 1.0);

                final borderColor = color.outline.withValues(alpha: 0.5);

                return Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: Spacing.xs + 2,
                  ),
                  child: InkWell(
                    onTap: () => onDistanceChanged(chip.key),
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
                            : Border.all(
                                color: borderColor,
                                width: Spacing.border,
                              ),
                      ),
                      child: Text(
                        chip.label,
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
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

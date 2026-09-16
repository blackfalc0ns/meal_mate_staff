import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'dispatcher_driver_filter_card_frame.dart';

class DispatcherDriverFilterOrdersSection extends StatelessWidget {
  const DispatcherDriverFilterOrdersSection({
    super.key,
    required this.completedOrders,
    required this.onOrdersChanged,
  });

  final int? completedOrders;
  final ValueChanged<int?> onOrdersChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final currentVal = (completedOrders?.toDouble() ?? 1000.0).clamp(
      0.0,
      1000.0,
    );

    final orderChips = [
      (key: null, label: locale.driverFilterAllStatuses),
      (key: 20, label: locale.driverFilterOrdersRange20),
      (key: 50, label: locale.driverFilterOrdersRange50),
      (key: 100, label: locale.driverFilterOrdersRange100),
      (key: 500, label: locale.driverFilterOrdersRange500),
      (key: 1000, label: locale.driverFilterOrdersRange500Plus),
    ];

    return DispatcherDriverFilterCardFrame(
      title: locale.driverFilterByCompletedOrders,
      icon: Icon(
        Icons.inventory_2_rounded,
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
                locale.driverFilterOrders0,
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
                    max: 1000.0,
                    onChanged: (val) => onOrdersChanged(val.toInt()),
                  ),
                ),
              ),
              Text(
                locale.driverFilterOrders1000Plus,
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
              children: orderChips.map((chip) {
                final isSelected = chip.key == null
                    ? completedOrders == null
                    : (completedOrders != null && completedOrders == chip.key);

                final borderColor = color.outline.withValues(alpha: 0.5);

                return Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: Spacing.xs + 2,
                  ),
                  child: InkWell(
                    onTap: () => onOrdersChanged(chip.key),
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

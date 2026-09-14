import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'driver_filter_card_frame.dart';

class DriverFilterAreaSection extends StatelessWidget {
  const DriverFilterAreaSection({
    super.key,
    required this.selectedArea,
    required this.onAreaSelected,
  });

  final String? selectedArea;
  final ValueChanged<String?> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final areas = [
      (key: null, label: locale.driverFilterAllAreas),
      (key: 'salmiya', label: locale.driverFilterSalmiya),
      (key: 'hawalli', label: locale.driverFilterHawalli),
      (key: 'hiteen', label: locale.driverFilterHiteen),
      (key: 'farwaniya', label: locale.driverFilterFarwaniya),
      (key: 'capital', label: locale.driverFilterCapital),
    ];

    return DriverFilterCardFrame(
      title: locale.driverFilterByArea,
      icon: Icon(
        Icons.location_on_rounded,
        size: Spacing.iconSm,
        color: color.primary,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: areas.map((area) {
            final isSelected = selectedArea == area.key;

            final borderColor = color.outline.withValues(alpha: 0.5);

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: Spacing.xs + 2),
              child: InkWell(
                onTap: () => onAreaSelected(area.key),
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
                      if (!isSelected && area.key != null) ...[
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: color.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.xs),
                      ],
                      Text(
                        area.label,
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

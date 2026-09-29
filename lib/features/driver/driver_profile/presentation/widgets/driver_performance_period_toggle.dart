import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformancePeriodToggle extends StatelessWidget {
  const DriverPerformancePeriodToggle({
    super.key,
    required this.isTodaySelected,
    required this.onToggle,
  });

  final bool isTodaySelected;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outline.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onToggle(true),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isTodaySelected ? color.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Text(
                  locale.driverPerformanceToday,
                  style: getMediumStyle(
                    fontSize: FontSize.size13,
                    color: isTodaySelected ? color.onPrimary : color.primary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onToggle(false),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isTodaySelected ? color.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Text(
                  locale.driverPerformanceThisWeek,
                  style: getMediumStyle(
                    fontSize: FontSize.size13,
                    color: !isTodaySelected ? color.onPrimary : color.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

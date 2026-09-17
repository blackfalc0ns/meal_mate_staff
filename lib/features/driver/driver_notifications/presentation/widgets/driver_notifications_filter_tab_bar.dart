import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_notification_filter_type.dart';

class DriverNotificationsFilterTabBar extends StatelessWidget {
  const DriverNotificationsFilterTabBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final DriverNotificationFilterType selectedFilter;
  final ValueChanged<DriverNotificationFilterType> onFilterChanged;

  static const double _indicatorHeight = 2.5;

  String _getFilterLabel(
    DriverNotificationFilterType filter,
    dynamic locale,
  ) {
    switch (filter) {
      case DriverNotificationFilterType.all:
        return locale.driverNotificationsFilterAll;
      case DriverNotificationFilterType.deliveryOrders:
        return locale.driverNotificationsFilterDelivery;
      case DriverNotificationFilterType.offers:
        return locale.driverNotificationsFilterOffers;
      case DriverNotificationFilterType.system:
        return locale.driverNotificationsFilterSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color.outline,
            width: Spacing.border,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: DriverNotificationFilterType.values.map((filter) {
                  final isSelected = filter == selectedFilter;
                  final label = _getFilterLabel(filter, locale);

                  return InkWell(
                    onTap: () => onFilterChanged(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.base,
                        vertical: Spacing.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? color.primary
                                : color.surface.withValues(alpha: 0),
                            width: _indicatorHeight,
                          ),
                        ),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: isSelected
                            ? getBoldStyle(
                                color: color.primary,
                                fontSize: FontSize.size13,
                              )
                            : getRegularStyle(
                                color: color.onSurfaceVariant,
                                fontSize: FontSize.size13,
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

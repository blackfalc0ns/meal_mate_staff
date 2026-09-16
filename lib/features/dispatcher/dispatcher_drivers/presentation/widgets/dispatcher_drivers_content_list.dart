import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import 'dispatcher_drivers_card.dart';
import 'dispatcher_drivers_section_header.dart';

class DispatcherDriversContentList extends StatelessWidget {
  const DispatcherDriversContentList({
    super.key,
    required this.transitionKey,
    required this.isTransitionReversed,
    required this.sectionTitle,
    required this.drivers,
    required this.onSort,
    this.onSelectDriver,
  });

  final Object transitionKey;
  final bool isTransitionReversed;
  final String sectionTitle;
  final List<DispatcherDriverEntity> drivers;
  final VoidCallback onSort;
  final ValueChanged<DispatcherDriverEntity>? onSelectDriver;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      reverse: isTransitionReversed,
      transitionBuilder:
          (
            Widget child,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: color.surface,
              child: child,
            );
          },
      child: Column(
        key: ValueKey(transitionKey),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DispatcherDriversSectionHeader(title: sectionTitle, onSort: onSort),
          const SizedBox(height: Spacing.xs),
          ...drivers.map(
            (driver) => DispatcherDriversCard(
              key: ValueKey(driver.id),
              driver: driver,
              onSelect: onSelectDriver,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/dispatcher_map_driver_marker_entity.dart';
import 'dispatcher_map_driver_card.dart';

class DispatcherMapDriversCarousel extends StatelessWidget {
  const DispatcherMapDriversCarousel({
    super.key,
    required this.drivers,
    this.selectedDriverId,
    this.onSelectDriver,
  });

  final List<DispatcherMapDriverMarkerEntity> drivers;
  final String? selectedDriverId;
  final ValueChanged<DispatcherMapDriverMarkerEntity>? onSelectDriver;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Spacing.dispatcherMapBottomCarouselHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.xs,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: drivers.length,
        separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final driver = drivers[index];
          final isSelected = driver.id == selectedDriverId;

          return DispatcherMapDriverCard(
            driver: driver,
            isSelected: isSelected,
            onTap: () => onSelectDriver?.call(driver),
          );
        },
      ),
    );
  }
}

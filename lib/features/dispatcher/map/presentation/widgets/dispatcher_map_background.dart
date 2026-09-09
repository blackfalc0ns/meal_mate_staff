import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../domain/entities/dispatcher_map_driver_marker_entity.dart';
import 'dispatcher_map_marker_item.dart';

class DispatcherMapBackground extends StatelessWidget {
  const DispatcherMapBackground({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.dispatcherMapStaticBackground,
              fit: BoxFit.cover,
            ),
            for (final driver in drivers)
              Positioned(
                left: (width * driver.mapRelativeX) -
                    (Spacing.dispatcherMapMarkerAvatarSize / 2),
                top: (height * driver.mapRelativeY) -
                    (Spacing.dispatcherMapMarkerAvatarSize / 2),
                child: DispatcherMapMarkerItem(
                  driver: driver,
                  isSelected: driver.id == selectedDriverId,
                  onTap: () => onSelectDriver?.call(driver),
                ),
              ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';

import 'driver_active_location_chip.dart';
import 'driver_active_status_chip.dart';

class DriverActiveStatusLocationRow extends StatelessWidget {
  const DriverActiveStatusLocationRow({
    super.key,
    required this.location,
    this.statusText,
  });

  final String location;
  final String? statusText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DriverActiveLocationChip(location: location),
        ),
        const SizedBox(width: Spacing.sm),
        DriverActiveStatusChip(statusText: statusText),
      ],
    );
  }
}

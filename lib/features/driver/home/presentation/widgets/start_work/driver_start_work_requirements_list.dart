import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_start_work_requirement_entity.dart';

import 'driver_start_work_requirement_tile.dart';

class DriverStartWorkRequirementsList extends StatelessWidget {
  const DriverStartWorkRequirementsList({
    super.key,
    required this.requirements,
    this.onRequirementTap,
  });

  final List<DriverStartWorkRequirementEntity> requirements;
  final ValueChanged<DriverStartWorkRequirementEntity>? onRequirementTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(requirements.length, (index) {
        final req = requirements[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < requirements.length - 1 ? Spacing.sm : Spacing.zero,
          ),
          child: DriverStartWorkRequirementTile(
            requirement: req,
            onTap: () => onRequirementTap?.call(req),
          ),
        );
      }),
    );
  }
}

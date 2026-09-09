import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import 'dispatcher_drivers_area_chip.dart';

class DispatcherDriversAreaChips extends StatelessWidget {
  const DispatcherDriversAreaChips({
    super.key,
    required this.areas,
    required this.selectedArea,
    required this.onAreaSelected,
  });

  final List<String> areas;
  final String selectedArea;
  final ValueChanged<String> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Spacing.registrationSmallButtonHeight + Spacing.border,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        itemCount: areas.length,
        separatorBuilder: (_, _) => const SizedBox(width: Spacing.xs),
        itemBuilder: (context, index) {
          final area = areas[index];
          final isSelected = area == selectedArea;

          return DispatcherDriversAreaChip(
            area: area,
            isSelected: isSelected,
            onTap: () => onAreaSelected(area),
          );
        },
      ),
    );
  }
}

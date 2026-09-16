import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';

class ReassignDriverRadioIndicator extends StatelessWidget {
  const ReassignDriverRadioIndicator({super.key, required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      width: Spacing.lg,
      height: Spacing.lg,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.surface,
        border: Border.all(
          color: isSelected ? color.primary : color.outlineVariant,
          width: isSelected ? Spacing.border * 2 : Spacing.border * 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: Spacing.sm + Spacing.border * 2,
                height: Spacing.sm + Spacing.border * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.primary,
                ),
              ),
            )
          : null,
    );
  }
}

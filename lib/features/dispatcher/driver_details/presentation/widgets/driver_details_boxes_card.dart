import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_active_box_entity.dart';
import 'driver_details_box_item.dart';

class DriverDetailsBoxesCard extends StatelessWidget {
  const DriverDetailsBoxesCard({
    super.key,
    required this.boxes,
    this.onSelectBox,
  });

  final List<DriverActiveBoxEntity> boxes;
  final ValueChanged<DriverActiveBoxEntity>? onSelectBox;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.xs / 2,
              ),
              child: Text(
                locale.driverDetailsActiveBoxesTitle(boxes.length),
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size14,
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            ...boxes.map(
              (box) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: DriverDetailsBoxItem(
                  box: box,
                  onTap: () => onSelectBox?.call(box),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

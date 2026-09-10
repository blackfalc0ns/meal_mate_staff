import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_kpi_entity.dart';

class DispatcherHomeKpiRow extends StatelessWidget {
  const DispatcherHomeKpiRow({
    super.key,
    required this.items,
  });

  final List<DispatcherHomeKpiItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
            padding: const EdgeInsets.symmetric(
              vertical: Spacing.sm,
              horizontal: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              border: Border.all(
                color: color.outlineVariant.withValues(alpha: 0.35),
                width: Spacing.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.shadow.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  item.iconAsset,
                  width: Spacing.iconMd,
                  height: Spacing.iconMd,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  item.value,
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size16,
                    color: color.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  item.label,
                  style: getRegularStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size9,
                    color: color.homeMutedText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

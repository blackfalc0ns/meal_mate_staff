import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverDetailsKpiCard extends StatelessWidget {
  const DriverDetailsKpiCard({
    super.key,
    required this.svgAsset,
    required this.value,
    required this.label,
    this.iconColor,
  });

  final String svgAsset;
  final String value;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs / 2,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: Spacing.iconMd - Spacing.xs / 2,
            height: Spacing.iconMd - Spacing.xs / 2,
            colorFilter: iconColor != null
                ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                : null,
          ),
          const SizedBox(height: Spacing.xs / 2),
          Text(
            value,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size16,
            ),
          ),
          const SizedBox(height: Spacing.xs / 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: getMediumStyle(
                color: color.onSurfaceVariant,
                fontSize: FontSize.size9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

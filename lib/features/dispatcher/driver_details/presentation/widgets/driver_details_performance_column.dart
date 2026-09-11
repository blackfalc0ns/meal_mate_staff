import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverDetailsPerformanceColumn extends StatelessWidget {
  const DriverDetailsPerformanceColumn({
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgAsset,
          width: Spacing.iconSm + Spacing.xs / 2,
          height: Spacing.iconSm + Spacing.xs / 2,
          colorFilter: iconColor != null
              ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
              : null,
        ),
        const SizedBox(height: Spacing.xs / 2),
        Text(
          value,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size14,
          ),
        ),
        const SizedBox(height: Spacing.xs / 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size10,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverComparisonMetricCell extends StatelessWidget {
  const DriverComparisonMetricCell({
    super.key,
    required this.child,
    this.width,
    this.height = 48,
    this.backgroundColor,
  });

  factory DriverComparisonMetricCell.label({
    Key? key,
    required String label,
    IconData? icon,
    double? width = 120,
    double height = 48,
    Color? backgroundColor,
    required BuildContext context,
  }) {
    final color = context.colorScheme;
    return DriverComparisonMetricCell(
      key: key,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color.primary),
              const SizedBox(width: Spacing.xs),
            ],
            Expanded(
              child: Text(
                label,
                style: getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size11,
                  color: color.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final Widget child;
  final double? width;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      alignment: Alignment.center,
      child: child,
    );
  }
}

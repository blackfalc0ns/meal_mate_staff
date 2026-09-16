import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherSupportKpiCard extends StatelessWidget {
  const DispatcherSupportKpiCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.statusColor,
    required this.backgroundColor,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color statusColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      height: Spacing.dispatcherSupportKpiCardHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: Spacing.iconXs,
                color: statusColor,
              ),
              const SizedBox(width: Spacing.border * 2),
              Flexible(
                child: Text(
                  title,
                  style: getRegularStyle(
                    fontSize: FontSize.size9,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.border),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count.toString(),
              style: getBoldStyle(
                fontSize: FontSize.size18,
                color: statusColor,
              ),
            ),
          ),
          Text(
            locale.supportIssuesCountLabel,
            style: getRegularStyle(
              fontSize: FontSize.size9,
              color: color.onSurfaceVariant,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

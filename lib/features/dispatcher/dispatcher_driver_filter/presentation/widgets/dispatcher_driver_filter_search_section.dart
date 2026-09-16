import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'dispatcher_driver_filter_card_frame.dart';

class DispatcherDriverFilterSearchSection extends StatelessWidget {
  const DispatcherDriverFilterSearchSection({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DispatcherDriverFilterCardFrame(
      title: locale.driverFilterSearchTitle,
      icon: Icon(
        Icons.search_rounded,
        size: Spacing.iconSm,
        color: color.primary,
      ),
      child: Container(
        height: Spacing.buttonSmallHeight,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(
            color: color.outline.withValues(alpha: 0.5),
            width: Spacing.border,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: getRegularStyle(
            color: color.onSurface,
            fontSize: FontSize.size12,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: locale.driverFilterSearchHint,
            hintStyle: getRegularStyle(
              color: color.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: FontSize.size11,
            ),
          ),
        ),
      ),
    );
  }
}

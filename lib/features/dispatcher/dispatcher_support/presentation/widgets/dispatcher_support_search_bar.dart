import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherSupportSearchBar extends StatelessWidget {
  const DispatcherSupportSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Container(
        height: Spacing.dispatcherSupportSearchHeight,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: Spacing.iconSm,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: getRegularStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: locale.supportSearchHint,
                  hintStyle: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              InkWell(
                onTap: () {
                  controller.clear();
                  onClear?.call();
                },
                child: Icon(
                  Icons.close_rounded,
                  size: Spacing.iconXs,
                  color: color.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

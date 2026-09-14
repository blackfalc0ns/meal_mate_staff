import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class OperationsSearchFilterBar extends StatelessWidget {
  const OperationsSearchFilterBar({
    super.key,
    required this.searchController,
    this.onChanged,
    this.onDateFilterTap,
    this.dateLabel,
  });

  final TextEditingController searchController;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onDateFilterTap;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              padding: const EdgeInsetsDirectional.only(
                start: Spacing.xs,
                end: Spacing.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: color.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onChanged,
                      style: getRegularStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: locale.operationsSearchPlaceholder,
                        hintStyle: getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          // Date range filter dropdown
          InkWell(
            onTap: onDateFilterTap,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: color.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs / 2),
                  Text(
                    dateLabel ?? locale.operationsLast7Days,
                    style: getRegularStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size10,
                      color: color.onSurface,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs / 2),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: color.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

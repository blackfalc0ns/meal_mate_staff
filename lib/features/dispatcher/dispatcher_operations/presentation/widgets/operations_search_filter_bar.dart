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
    this.isEnabled = true,
    this.onClearSearch,
  });

  final TextEditingController searchController;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onDateFilterTap;
  final String? dateLabel;
  final bool isEnabled;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          // 1. Search input on the LEFT
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: color.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: searchController,
                        enabled: isEnabled,
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
                            color: color.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (context, value, _) {
                      if (value.text.isEmpty || !isEnabled) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          searchController.clear();
                          onClearSearch?.call();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: color.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // 2. Date filter on the RIGHT: [ v  آخر 7 أيام  📅 ]
          InkWell(
            onTap: isEnabled ? onDateFilterTap : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: isEnabled
                        ? color.primary
                        : color.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateLabel ?? locale.operationsLast7Days,
                    style: getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: isEnabled
                          ? color.primary
                          : color.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: isEnabled
                        ? color.primary
                        : color.onSurfaceVariant.withValues(alpha: 0.4),
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

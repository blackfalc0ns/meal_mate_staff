import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class OperationsPaginationBar extends StatelessWidget {
  const OperationsPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPreviousTap,
    this.onNextTap,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousTap;
  final VoidCallback? onNextTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final canGoPrev = currentPage > 1;
    final canGoNext = currentPage < totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          InkWell(
            onTap: canGoPrev ? onPreviousTap : null,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                border: Border.all(
                  color: canGoPrev
                      ? color.outlineVariant.withValues(alpha: 0.8)
                      : color.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: canGoPrev
                        ? color.onSurface
                        : color.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: Spacing.xs / 2),
                  Text(
                    locale.operationsPrevPage,
                    style: getMediumStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: canGoPrev
                          ? color.onSurface
                          : color.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Page Indicator
          Text(
            '$currentPage ${locale.operationsPageOf} $totalPages',
            style: getBoldStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size12,
              color: color.onSurface,
            ),
          ),

          // Next button
          InkWell(
            onTap: canGoNext ? onNextTap : null,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                border: Border.all(
                  color: canGoNext
                      ? color.outlineVariant.withValues(alpha: 0.8)
                      : color.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locale.operationsNextPage,
                    style: getMediumStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: canGoNext
                          ? color.onSurface
                          : color.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: Spacing.xs / 2),
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 16,
                    color: canGoNext
                        ? color.onSurface
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

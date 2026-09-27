import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_drivers_pagination_entity.dart';

class DispatcherDriversStatusPagination extends StatelessWidget {
  const DispatcherDriversStatusPagination({
    super.key,
    required this.pagination,
    required this.onPageChanged,
  });

  final DispatcherDriversPaginationEntity pagination;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    if (pagination.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            key: const Key('dispatcher_drivers_status_prev_page_button'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
            ),
            onPressed: pagination.hasPreviousPage
                ? () => onPageChanged(pagination.pageNumber - 1)
                : null,
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: Spacing.iconXs,
            ),
            label: Text(locale.driversStatusPrevPage),
          ),
          Text(
            locale.driversStatusPaginationPage(
              pagination.pageNumber,
              pagination.totalPages,
            ),
            style: getMediumStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size11,
              color: color.onSurfaceVariant,
            ),
          ),
          OutlinedButton.icon(
            key: const Key('dispatcher_drivers_status_next_page_button'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
            ),
            onPressed: pagination.hasNextPage
                ? () => onPageChanged(pagination.pageNumber + 1)
                : null,
            label: Text(locale.driversStatusNextPage),
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: Spacing.iconXs,
            ),
          ),
        ],
      ),
    );
  }
}

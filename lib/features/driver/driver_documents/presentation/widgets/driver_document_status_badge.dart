import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_document_item_entity.dart';

class DriverDocumentStatusBadge extends StatelessWidget {
  const DriverDocumentStatusBadge({
    super.key,
    required this.status,
  });

  final DriverDocumentItemStatus status;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final (String label, Color bg, Color fg, IconData icon) = switch (status) {
      DriverDocumentItemStatus.approved => (
          locale.driverDocumentStatusApproved,
          color.tertiaryContainer,
          color.tertiary,
          Icons.check_circle_outline_rounded,
        ),
      DriverDocumentItemStatus.expiringSoon => (
          locale.driverDocumentStatusExpiringSoon,
          color.secondaryContainer,
          color.onSecondaryContainer,
          Icons.schedule_rounded,
        ),
      DriverDocumentItemStatus.underReview => (
          locale.driverDocumentStatusUnderReview,
          color.primaryContainer,
          color.primary,
          Icons.hourglass_empty_rounded,
        ),
      DriverDocumentItemStatus.expired => (
          locale.driverDocumentStatusExpired,
          color.errorContainer,
          color.error,
          Icons.error_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: fg,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            label,
            style: getMediumStyle(
              fontSize: FontSize.size10,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

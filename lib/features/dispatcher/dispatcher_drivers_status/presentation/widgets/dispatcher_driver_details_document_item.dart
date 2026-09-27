import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_document_entity.dart';

class DispatcherDriverDetailsDocumentItem extends StatelessWidget {
  const DispatcherDriverDetailsDocumentItem({
    super.key,
    required this.document,
    this.onTap,
  });

  final DispatcherDriverDocumentEntity document;
  final VoidCallback? onTap;

  String _getDocumentTitle(
    BuildContext context,
    DispatcherDriverDocumentType type,
  ) {
    final locale = context.localization;
    return switch (type) {
      DispatcherDriverDocumentType.drivingLicense =>
        locale.driverDetailsDrivingLicense,
      DispatcherDriverDocumentType.vehicleRegistration =>
        locale.driverDetailsVehicleRegistration,
      DispatcherDriverDocumentType.insurance => locale.driverDetailsInsurance,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final title = _getDocumentTitle(context, document.type);
    final String statusText;
    final Color statusColor;
    final IconData statusIcon;

    switch (document.status) {
      case DispatcherDriverDocumentStatus.valid:
        statusColor = color.tertiary;
        statusIcon = Icons.check_circle_rounded;
        statusText =
            document.validUntil != null && document.validUntil!.isNotEmpty
            ? locale.driverDetailsValidUntil(document.validUntil!)
            : locale.driverDetailsDocumentValid;
      case DispatcherDriverDocumentStatus.expiringSoon:
        statusColor = color.secondary;
        statusIcon = Icons.warning_amber_rounded;
        statusText =
            document.validUntil != null && document.validUntil!.isNotEmpty
            ? locale.driverDetailsValidUntil(document.validUntil!)
            : locale.driverDetailsDocumentExpiringSoon;
      case DispatcherDriverDocumentStatus.expired:
        statusColor = color.error;
        statusIcon = Icons.cancel_outlined;
        statusText = locale.driverDetailsDocumentExpired;
      case DispatcherDriverDocumentStatus.missing:
      case DispatcherDriverDocumentStatus.unknown:
        statusColor = color.onSurfaceVariant;
        statusIcon = Icons.help_outline_rounded;
        statusText = locale.driverDetailsDocumentMissing;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs * 1.5,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.5),
            width: Spacing.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: Spacing.iconXs * 0.7,
                  color: color.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs / 2),
            Row(
              children: [
                Icon(statusIcon, size: Spacing.iconXs, color: statusColor),
                const SizedBox(width: Spacing.xs / 4),
                Expanded(
                  child: Text(
                    statusText,
                    style: getRegularStyle(
                      color: statusColor,
                      fontSize: FontSize.size10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

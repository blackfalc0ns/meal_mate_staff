import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../domain/entities/driver_document_item_entity.dart';
import 'driver_document_status_badge.dart';

class DriverDocumentPreviewDialog extends StatelessWidget {
  const DriverDocumentPreviewDialog({
    super.key,
    required this.document,
  });

  final DriverDocumentItemEntity document;

  static Future<void> show({
    required BuildContext context,
    required DriverDocumentItemEntity document,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => DriverDocumentPreviewDialog(document: document),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final documentTitle = switch (document.id) {
      'civil-card' => locale.registrationCivilCard,
      'driving-license' => locale.registrationDrivingLicense,
      'car-registration' => locale.registrationCarRegistration,
      'vehicle-photo' => locale.registrationVehiclePhoto,
      'personal-photo' => locale.registrationPersonalPhoto,
      _ => document.documentType,
    };

    return Dialog(
      backgroundColor: color.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documentTitle,
                        style: getBoldStyle(
                          fontSize: FontSize.size14,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      DriverDocumentStatusBadge(status: document.status),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: color.onSurfaceVariant,
                    size: Spacing.iconMd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.base),
            // Image Preview Container with zoom support
            Container(
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                border: Border.all(
                  color: color.outlineVariant,
                  width: Spacing.border,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: InteractiveViewer(
                  maxScale: 3.0,
                  child: Image.asset(
                    document.imageAsset,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(Spacing.xl),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.base),
            // Expiry Date text if available
            if (document.expiryDate != null &&
                document.expiryDate!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: color.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    '${locale.driverDocumentExpiry}: ${document.expiryDate}',
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.base),
            ],
            // Close Button
            AppButton(
              text: locale.driverDocumentClose,
              onPressed: () => Navigator.of(context).pop(),
              color: color.primary,
              textColor: color.onPrimary,
              borderRadius: Spacing.cardRadius,
              height: Spacing.buttonSmallHeight,
            ),
          ],
        ),
      ),
    );
  }
}

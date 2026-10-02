import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../domain/entities/driver_document_item_entity.dart';
import 'driver_document_status_badge.dart';

class DriverDocumentCard extends StatelessWidget {
  const DriverDocumentCard({
    super.key,
    required this.document,
    required this.onViewTap,
    required this.onUpdateTap,
  });

  final DriverDocumentItemEntity document;
  final VoidCallback onViewTap;
  final VoidCallback onUpdateTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final (String title, String subtitle) = switch (document.id) {
      'civil-card' => (
          locale.registrationCivilCard,
          locale.registrationCivilCardSubtitle,
        ),
      'driving-license' => (
          locale.registrationDrivingLicense,
          locale.registrationDrivingLicenseSubtitle,
        ),
      'car-registration' => (
          locale.registrationCarRegistration,
          locale.registrationCarRegistrationSubtitle,
        ),
      'vehicle-photo' => (
          locale.registrationVehiclePhoto,
          locale.registrationVehiclePhotoSubtitle,
        ),
      'personal-photo' => (
          locale.registrationPersonalPhoto,
          locale.registrationPersonalPhotoSubtitle,
        ),
      _ => (
          document.documentType,
          '',
        ),
    };

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: color.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.onSurface,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              DriverDocumentStatusBadge(status: document.status),
            ],
          ),
          if (document.expiryDate != null &&
              document.expiryDate!.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: color.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    '${locale.driverDocumentExpiry}: ${document.expiryDate}',
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Spacing.md),
          // Action Buttons: View Photo & Update Document
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: locale.driverDocumentViewPhoto,
                  icon: Icons.visibility_outlined,
                  onPressed: onViewTap,
                  variant: AppButtonVariant.outlined,
                  height: Spacing.buttonSmallHeight,
                  borderRadius: Spacing.radiusSm,
                  color: color.primary,
                  textColor: color.primary,
                  textStyle: getMediumStyle(
                    fontSize: FontSize.size12,
                    color: color.primary,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: AppButton(
                  text: locale.driverDocumentChangeButton,
                  icon: Icons.edit_outlined,
                  onPressed: onUpdateTap,
                  height: Spacing.buttonSmallHeight,
                  borderRadius: Spacing.radiusSm,
                  color: color.primary,
                  textColor: color.onPrimary,
                  textStyle: getMediumStyle(
                    fontSize: FontSize.size12,
                    color: color.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

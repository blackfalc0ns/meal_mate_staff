import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../../../../core/widget/custom_bottom_sheet.dart';
import '../../domain/entities/driver_document_item_entity.dart';

class DriverEditDocumentSheet extends StatefulWidget {
  const DriverEditDocumentSheet({
    super.key,
    required this.document,
    required this.onDocumentUpdated,
  });

  final DriverDocumentItemEntity document;
  final ValueChanged<DriverDocumentItemEntity> onDocumentUpdated;

  static Future<void> show({
    required BuildContext context,
    required DriverDocumentItemEntity document,
    required ValueChanged<DriverDocumentItemEntity> onDocumentUpdated,
  }) {
    return CustomBottomSheet.show(
      context: context,
      title: context.localization.driverDocumentUploadNew,
      subtitle: context.localization.driverDocumentUploadHint,
      child: DriverEditDocumentSheet(
        document: document,
        onDocumentUpdated: onDocumentUpdated,
      ),
    );
  }

  @override
  State<DriverEditDocumentSheet> createState() =>
      _DriverEditDocumentSheetState();
}

class _DriverEditDocumentSheetState extends State<DriverEditDocumentSheet> {
  int _selectedSourceIndex = 0;
  bool _isSubmitting = false;

  void _handleConfirm() {
    setState(() {
      _isSubmitting = true;
    });

    final updated = widget.document.copyWith(
      status: DriverDocumentItemStatus.underReview,
      uploadedAt: DateTime.now(),
    );

    widget.onDocumentUpdated(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final documentTitle = switch (widget.document.id) {
      'civil-card' => locale.registrationCivilCard,
      'driving-license' => locale.registrationDrivingLicense,
      'car-registration' => locale.registrationCarRegistration,
      'vehicle-photo' => locale.registrationVehiclePhoto,
      'personal-photo' => locale.registrationPersonalPhoto,
      _ => widget.document.documentType,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Target Document Indicator
        Container(
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: color.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            border: Border.all(
              color: color.outlineVariant,
              width: Spacing.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.file_present_rounded,
                size: 20,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  documentTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        // Source Selection Row
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedSourceIndex = 0),
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Spacing.md,
                    horizontal: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedSourceIndex == 0
                        ? color.primaryContainer.withValues(alpha: 0.3)
                        : color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    border: Border.all(
                      color: _selectedSourceIndex == 0
                          ? color.primary
                          : color.outlineVariant,
                      width: _selectedSourceIndex == 0 ? 1.5 : Spacing.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 28,
                        color: _selectedSourceIndex == 0
                            ? color.primary
                            : color.onSurfaceVariant,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.driverDocumentFromGallery,
                        style: getMediumStyle(
                          fontSize: FontSize.size12,
                          color: _selectedSourceIndex == 0
                              ? color.primary
                              : color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedSourceIndex = 1),
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Spacing.md,
                    horizontal: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedSourceIndex == 1
                        ? color.primaryContainer.withValues(alpha: 0.3)
                        : color.surface,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    border: Border.all(
                      color: _selectedSourceIndex == 1
                          ? color.primary
                          : color.outlineVariant,
                      width: _selectedSourceIndex == 1 ? 1.5 : Spacing.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 28,
                        color: _selectedSourceIndex == 1
                            ? color.primary
                            : color.onSurfaceVariant,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.driverDocumentFromCamera,
                        style: getMediumStyle(
                          fontSize: FontSize.size12,
                          color: _selectedSourceIndex == 1
                              ? color.primary
                              : color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        // Confirm Button
        AppButton(
          text: locale.driverDocumentConfirmUpload,
          icon: Icons.cloud_upload_outlined,
          isLoading: _isSubmitting,
          onPressed: _handleConfirm,
          color: color.primary,
          textColor: color.onPrimary,
          borderRadius: Spacing.cardRadius,
          height: Spacing.buttonHeight,
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }
}

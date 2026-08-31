import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/register_document.dart';
import 'register_document_preview.dart';

class RegisterDocumentUploadCard extends StatelessWidget {
  const RegisterDocumentUploadCard({
    super.key,
    required this.document,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selectedImagePath,
  });

  final RegisterDocument document;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? selectedImagePath;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final isUploaded = document.isUploaded || selectedImagePath != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        Spacing.registrationDocumentCardRadius,
      ),
      child: SizedBox(
        height: Spacing.registrationDocumentCardHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.surface,
            border: Border.all(color: color.outline),
            borderRadius: BorderRadius.circular(
              Spacing.registrationDocumentCardRadius,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.registrationDocumentCardHorizontal,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: color.primary,
                  size: Spacing.iconLg,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: getSemiBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size9,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        subtitle,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size7,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isUploaded
                                ? color.tertiaryContainer
                                : color.secondaryContainer,
                            borderRadius: BorderRadius.circular(
                              Spacing.radiusXs,
                            ),
                          ),
                          child: SizedBox(
                            height: Spacing.registrationDocumentBadgeHeight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isUploaded) ...[
                                    Icon(
                                      Icons.check,
                                      color: color.tertiary,
                                      size: FontSize.size9,
                                    ),
                                    const SizedBox(width: Spacing.xs),
                                  ],
                                  Text(
                                    isUploaded
                                        ? locale.registrationUploaded
                                        : locale.registrationRequired,
                                    style: getRegularStyle(
                                      color: isUploaded
                                          ? color.tertiary
                                          : color.secondary,
                                      fontSize: FontSize.size8,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.xxl),
                RegisterDocumentPreview(
                  document: document,
                  isUploaded: isUploaded,
                  selectedImagePath: selectedImagePath,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

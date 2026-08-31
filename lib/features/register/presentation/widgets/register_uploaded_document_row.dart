import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/register_document.dart';

class RegisterUploadedDocumentRow extends StatelessWidget {
  const RegisterUploadedDocumentRow({
    super.key,
    required this.document,
    required this.title,
    required this.onTap,
    this.selectedImagePath,
  });

  final RegisterDocument document;
  final String title;
  final VoidCallback onTap;
  final String? selectedImagePath;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.registrationRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.radiusXs),
              child: SizedBox.square(
                dimension: Spacing.iconMd,
                child: selectedImagePath == null
                    ? Image.asset(document.imageAsset, fit: BoxFit.cover)
                    : Image.file(File(selectedImagePath!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                title,
                style: getMediumStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size10,
                  height: 1.3,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.tertiaryContainer,
                borderRadius: BorderRadius.circular(Spacing.radiusXs),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs,
                  vertical: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: color.tertiary,
                      size: FontSize.size9,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      document.isUploaded
                          ? locale.registrationUploaded
                          : locale.registrationTapToUpload,
                      style: getSemiBoldStyle(
                        color: color.tertiary,
                        fontSize: FontSize.size10,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

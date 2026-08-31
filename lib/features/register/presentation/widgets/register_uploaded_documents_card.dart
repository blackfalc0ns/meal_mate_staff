import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../domain/register_document.dart';
import 'register_uploaded_document_row.dart';

class RegisterUploadedDocumentsCard extends StatelessWidget {
  const RegisterUploadedDocumentsCard({
    super.key,
    required this.documents,
    required this.documentTitles,
    required this.selectedImagePaths,
    required this.onDocumentTap,
  });

  final List<RegisterDocument> documents;
  final Map<String, String> documentTitles;
  final Map<String, String> selectedImagePaths;
  final ValueChanged<RegisterDocument> onDocumentTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(
          Spacing.registrationReviewCardRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    locale.registrationUploadedDocuments,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  color: color.primary,
                  size: Spacing.iconSm,
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            ...documents.map(
              (document) => RegisterUploadedDocumentRow(
                document: document,
                title: documentTitles[document.id] ?? locale.registrationOther,
                selectedImagePath: selectedImagePaths[document.id],
                onTap: () => onDocumentTap(document),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

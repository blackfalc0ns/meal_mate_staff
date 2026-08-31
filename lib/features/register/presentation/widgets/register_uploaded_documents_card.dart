import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';
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
    final borderSide = BorderSide(color: color.outline);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border.all(color: color.outline),
        borderRadius: BorderRadius.circular(
          Spacing.registrationReviewCardRadius,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
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
                      height: 1.5,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  width: Spacing.xxxl + Spacing.xl,
                  height: Spacing.xxl,
                  child: AppButton(
                    text: locale.registrationEdit,
                    onPressed: documents.isEmpty
                        ? null
                        : () => onDocumentTap(documents.first),
                    variant: AppButtonVariant.outlined,
                    icon: Icons.edit_outlined,
                    height: Spacing.xxl,
                    borderRadius: Spacing.registrationRadius,
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                    iconSize: Spacing.iconSm,
                    iconGap: Spacing.xs,
                    color: color.primary,
                    textColor: color.primary,
                    textStyle: getRegularStyle(
                      color: color.primary,
                      fontSize: FontSize.size9,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Table(
              key: const Key('register-uploaded-documents-table'),
              textDirection: Directionality.of(context),
              border: TableBorder(
                top: borderSide,
                bottom: borderSide,
                horizontalInside: borderSide,
              ),
              children: documents.map((document) {
                return TableRow(
                  children: [
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: RegisterUploadedDocumentRow(
                        document: document,
                        title:
                            documentTitles[document.id] ??
                            locale.registrationOther,
                        selectedImagePath: selectedImagePaths[document.id],
                        onTap: () => onDocumentTap(document),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

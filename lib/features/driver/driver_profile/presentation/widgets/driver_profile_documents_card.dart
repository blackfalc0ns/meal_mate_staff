import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_document_entity.dart';

enum DriverDocumentTone {
  danger,
  warning,
  success,
  pending,
  actionRequired,
  neutral,
}

DriverDocumentTone documentTone(String status) => switch (status) {
      'Expired' => DriverDocumentTone.danger,
      'ExpiringSoon' => DriverDocumentTone.warning,
      'Approved' => DriverDocumentTone.success,
      'Submitted' || 'UnderReview' => DriverDocumentTone.pending,
      'Rejected' || 'NeedsChanges' || 'ResubmissionRequired' =>
        DriverDocumentTone.actionRequired,
      _ => DriverDocumentTone.neutral,
    };

class DriverProfileDocumentsCard extends StatelessWidget {
  const DriverProfileDocumentsCard({
    super.key,
    required this.documents,
  });

  final List<DriverProfileDocumentEntity> documents;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_shared_outlined,
                size: 20,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  locale.driverDocumentsTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (documents.isEmpty)
            Padding(
              key: const Key('driver_profile_documents_empty'),
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              child: Center(
                child: Text(
                  locale.driverDocumentsEmpty,
                  style: getRegularStyle(
                    fontSize: FontSize.size12,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: Spacing.md),
              itemBuilder: (context, index) {
                final doc = documents[index];
                final tone = documentTone(doc.status);
                final statusKey =
                    'driver_document_status_${doc.status.toLowerCase()}';

                Color badgeBg;
                Color badgeFg;
                switch (tone) {
                  case DriverDocumentTone.danger:
                  case DriverDocumentTone.actionRequired:
                    badgeBg = color.errorContainer;
                    badgeFg = color.error;
                  case DriverDocumentTone.warning:
                    badgeBg = Colors.amber.withValues(alpha: 0.15);
                    badgeFg = Colors.amber.shade800;
                  case DriverDocumentTone.success:
                    badgeBg = color.tertiaryContainer;
                    badgeFg = color.tertiary;
                  case DriverDocumentTone.pending:
                    badgeBg = color.primaryContainer;
                    badgeFg = color.primary;
                  case DriverDocumentTone.neutral:
                    badgeBg = color.surfaceContainerHighest;
                    badgeFg = color.onSurfaceVariant;
                }

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.documentTitle,
                            style: getMediumStyle(
                              fontSize: FontSize.size12,
                              color: color.onSurface,
                            ),
                          ),
                          if (doc.expiryDate != null &&
                              doc.expiryDate!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${locale.driverDocumentExpiry}: ${doc.expiryDate}',
                              style: getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Container(
                      key: Key(statusKey),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      ),
                      child: Text(
                        doc.statusText,
                        style: getMediumStyle(
                          fontSize: FontSize.size10,
                          color: badgeFg,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_document_entity.dart';
import 'dispatcher_driver_details_document_item.dart';

class DispatcherDriverDetailsDocumentsCard extends StatelessWidget {
  const DispatcherDriverDetailsDocumentsCard({
    super.key,
    required this.documents,
    this.onSelectDocument,
  });

  final List<DispatcherDriverDocumentEntity> documents;
  final ValueChanged<DispatcherDriverDocumentEntity>? onSelectDocument;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: Spacing.iconSm,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverDetailsDocumentsTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              for (int i = 0; i < documents.length; i++) ...[
                if (i > 0) const SizedBox(width: Spacing.xs),
                Expanded(
                  child: DispatcherDriverDetailsDocumentItem(
                    document: documents[i],
                    onTap: () => onSelectDocument?.call(documents[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

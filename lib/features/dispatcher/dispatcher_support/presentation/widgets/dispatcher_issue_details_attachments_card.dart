import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_issue_attachment_entity.dart';

class DispatcherIssueDetailsAttachmentsCard extends StatelessWidget {
  const DispatcherIssueDetailsAttachmentsCard({
    super.key,
    required this.attachments,
  });

  final List<DispatcherIssueAttachmentEntity> attachments;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.issueDetailsAttachmentsTitle,
            style: getBoldStyle(
              fontSize: FontSize.size12,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: Spacing.accountStatusResultImageHeight * 0.34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      child: Image.asset(
                        attachment.imageAsset,
                        width: Spacing.accountStatusResultImageWidth * 0.35,
                        height: Spacing.accountStatusResultImageHeight * 0.34,
                        fit: BoxFit.cover,
                      ),
                    ),
                    PositionedDirectional(
                      top: Spacing.xs,
                      end: Spacing.xs,
                      child: Container(
                        width: Spacing.lg,
                        height: Spacing.lg,
                        decoration: BoxDecoration(
                          color: color.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.surface,
                            width: Spacing.border * 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${attachment.orderNumber}',
                          style: getBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

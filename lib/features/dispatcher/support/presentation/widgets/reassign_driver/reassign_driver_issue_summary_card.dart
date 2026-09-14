import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_issue_detail_entity.dart';
import 'reassign_driver_current_driver_section.dart';
import 'reassign_driver_issue_header.dart';
import 'reassign_driver_issue_meta_row.dart';

class ReassignDriverIssueSummaryCard extends StatelessWidget {
  const ReassignDriverIssueSummaryCard({super.key, required this.issue});

  final DispatcherIssueDetailEntity issue;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReassignDriverIssueHeader(issue: issue),
          const SizedBox(height: Spacing.sm),
          Divider(color: color.outlineVariant, height: Spacing.border),
          const SizedBox(height: Spacing.sm),
          ReassignDriverIssueMetaRow(issue: issue),
          const SizedBox(height: Spacing.sm),
          Divider(color: color.outlineVariant, height: Spacing.border),
          const SizedBox(height: Spacing.sm),
          ReassignDriverCurrentDriverSection(issue: issue),
        ],
      ),
    );
  }
}

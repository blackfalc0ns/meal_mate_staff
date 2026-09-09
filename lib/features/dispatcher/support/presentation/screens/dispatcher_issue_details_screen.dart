import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../../../core/widget/notification_button.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';
import '../../domain/fake_data/dispatcher_issue_detail_fake_data.dart';
import '../widgets/dispatcher_issue_details_action_buttons.dart';
import '../widgets/dispatcher_issue_details_attachments_card.dart';
import '../widgets/dispatcher_issue_details_description_card.dart';
import '../widgets/dispatcher_issue_details_driver_card.dart';
import '../widgets/dispatcher_issue_details_header_card.dart';
import '../widgets/dispatcher_issue_details_trip_card.dart';

class DispatcherIssueDetailsScreen extends StatelessWidget {
  const DispatcherIssueDetailsScreen({
    super.key,
    this.issue,
  });

  final DispatcherIssueDetailEntity? issue;

  void _onAssignReplacement(BuildContext context) {
    context.pushNamed(AppRoutes.assignBox);
  }

  void _onContactDriver(BuildContext context, String driverName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$driverName...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final currentIssue = issue ?? DispatcherIssueDetailFakeData.sampleIssueDetail;

    return Scaffold(
      backgroundColor: color.surfaceContainerLowest,
      appBar: CustomAppBar(
        title: locale.issueDetailsTitle,
        centerTitle: true,
        actions: [
          NotificationButton(
            hasUnread: true,
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DispatcherIssueDetailsHeaderCard(issue: currentIssue),
              const SizedBox(height: Spacing.sm),
              DispatcherIssueDetailsDriverCard(issue: currentIssue),
              const SizedBox(height: Spacing.sm),
              DispatcherIssueDetailsDescriptionCard(
                description: currentIssue.description,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherIssueDetailsAttachmentsCard(
                attachments: currentIssue.attachments,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherIssueDetailsTripCard(issue: currentIssue),
              const SizedBox(height: Spacing.sm),
              DispatcherIssueDetailsActionButtons(
                onAssignReplacementTap: () => _onAssignReplacement(context),
                onContactDriverTap: () => _onContactDriver(
                  context,
                  currentIssue.driverName,
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

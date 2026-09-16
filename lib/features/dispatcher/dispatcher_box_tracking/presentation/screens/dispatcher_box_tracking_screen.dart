import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/box_tracking_entity.dart';
import '../../domain/fake_data/box_tracking_fake_data.dart';
import '../widgets/box_tracking_app_bar.dart';
import '../widgets/box_tracking_details_card.dart';
import '../widgets/box_tracking_driver_card.dart';
import '../widgets/box_tracking_header_card.dart';
import '../widgets/box_tracking_report_issue_button.dart';
import '../widgets/box_tracking_timeline_card.dart';

class DispatcherBoxTrackingScreen extends StatelessWidget {
  const DispatcherBoxTrackingScreen({
    super.key,
    this.box = BoxTrackingFakeData.defaultBox,
    this.onBack,
    this.onMore,
    this.onLiveTracking,
    this.onSendMessage,
    this.onCall,
    this.onReportIssue,
  });

  final BoxTrackingEntity box;
  final VoidCallback? onBack;
  final VoidCallback? onMore;
  final VoidCallback? onLiveTracking;
  final VoidCallback? onSendMessage;
  final VoidCallback? onCall;
  final VoidCallback? onReportIssue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BoxTrackingAppBar(onBack: onBack, onMore: onMore),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenH,
            vertical: Spacing.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BoxTrackingHeaderCard(box: box),
              const SizedBox(height: Spacing.md),
              BoxTrackingTimelineCard(steps: box.steps),
              const SizedBox(height: Spacing.md),
              BoxTrackingDriverCard(
                driver: box.driver,
                onLiveTracking: onLiveTracking,
                onSendMessage: onSendMessage,
                onCall: onCall,
              ),
              const SizedBox(height: Spacing.md),
              BoxTrackingDetailsCard(box: box),
              const SizedBox(height: Spacing.lg),
              BoxTrackingReportIssueButton(onPressed: onReportIssue),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

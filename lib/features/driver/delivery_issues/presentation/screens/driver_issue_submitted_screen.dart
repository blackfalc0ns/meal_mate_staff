import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/delivery_issue_entity.dart';
import '../widgets/issue_return_home_button.dart';
import '../widgets/issue_submitted_card.dart';

class DriverIssueSubmittedScreen extends StatelessWidget {
  const DriverIssueSubmittedScreen({
    super.key,
    this.issue,
    this.onReturnHome,
  });

  final DeliveryIssueEntity? issue;
  final VoidCallback? onReturnHome;

  void _handleReturnHome(BuildContext context) {
    if (onReturnHome != null) {
      onReturnHome!();
      return;
    }

    unawaited(
      context.pushNamedAndRemoveUntil(
        AppRoutes.driverAppShell,
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenH,
            vertical: Spacing.screenV,
          ),
          child: Column(
            children: [
              const Spacer(),
              const IssueSubmittedCard(),
              const Spacer(),
              IssueReturnHomeButton(
                onPressed: () => _handleReturnHome(context),
              ),
              const SizedBox(height: Spacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

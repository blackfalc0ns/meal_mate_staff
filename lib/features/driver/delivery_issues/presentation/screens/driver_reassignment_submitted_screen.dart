import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/reassignment_request_entity.dart';
import '../widgets/issue_return_home_button.dart';
import '../widgets/reassignment_submitted_card.dart';

class DriverReassignmentSubmittedScreen extends StatelessWidget {
  const DriverReassignmentSubmittedScreen({
    super.key,
    this.request,
    this.onReturnHome,
  });

  final ReassignmentRequestEntity? request;
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
              const ReassignmentSubmittedCard(),
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

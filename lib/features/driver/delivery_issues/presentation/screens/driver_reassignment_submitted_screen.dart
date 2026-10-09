import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/reassignment_request_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../widgets/issue_return_home_button.dart';
import '../widgets/reassignment_submitted_card.dart';

class DriverReassignmentSubmittedScreen extends StatelessWidget {
  const DriverReassignmentSubmittedScreen({
    super.key,
    this.result,
    this.request,
    this.onReturnHome,
  });

  final ReassignmentResultEntity? result;
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
    final locale = context.localization;

    final hasValidResult = result != null && result!.requestId.isNotEmpty;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.screenH,
            vertical: Spacing.screenV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.xxl),
              if (hasValidResult)
                const ReassignmentSubmittedCard()
              else ...[
                const SizedBox(height: Spacing.xl),
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: color.error,
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  locale.reassignUnavailableContext,
                  style: getBoldStyle(
                    fontSize: FontSize.size18,
                    color: color.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: Spacing.xxl),
              IssueReturnHomeButton(
                onPressed: () => _handleReturnHome(context),
              ),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

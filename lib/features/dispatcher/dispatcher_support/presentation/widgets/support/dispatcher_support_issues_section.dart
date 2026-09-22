import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../config/routing/app_routes.dart';
import '../../../../../../config/routing/arguments/dispatcher_support_route_arguments.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_issue_workflow_result_entity.dart';
import '../../../domain/entities/dispatcher_support_issue_entity.dart';
import '../../../domain/entities/reassignment_result_entity.dart';
import '../../manager/dispatcher_support_event.dart';
import '../../manager/dispatcher_support_view_model.dart';
import 'dispatcher_support_empty_state.dart';
import 'dispatcher_support_issue_card.dart';

class DispatcherSupportIssuesSection extends StatelessWidget {
  const DispatcherSupportIssuesSection({
    super.key,
    required this.issues,
    required this.onRetry,
    this.onViewDetails,
    this.onAssignAlternativeDriver,
  });

  final List<DispatcherSupportIssueEntity> issues;
  final VoidCallback onRetry;
  final ValueChanged<DispatcherSupportIssueEntity>? onViewDetails;
  final ValueChanged<DispatcherSupportIssueEntity>? onAssignAlternativeDriver;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: DispatcherSupportEmptyState(onRetry: onRetry),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final issue = issues[index];
          return RepaintBoundary(
            key: ValueKey(issue.id),
            child: DispatcherSupportIssueCard(
              issue: issue,
              onTap: () => _handleViewDetails(context, issue),
              onViewDetails: () => _handleViewDetails(context, issue),
              onAssignAlternativeDriver: () =>
                  _handleAssignDriver(context, issue),
            ),
          );
        },
        childCount: issues.length,
        findChildIndexCallback: (key) {
          if (key is ValueKey<String>) {
            final index = issues.indexWhere((i) => i.id == key.value);
            return index == -1 ? null : index;
          }
          return null;
        },
      ),
    );
  }

  Future<void> _handleViewDetails(
    BuildContext context,
    DispatcherSupportIssueEntity issue,
  ) async {
    if (onViewDetails != null) {
      onViewDetails!(issue);
    } else {
      final result = await context.pushNamed(
        AppRoutes.dispatcherSupportIssueDetails,
        arguments: DispatcherSupportIssueDetailsRouteArgs(issueId: issue.id),
      );
      if (result is DispatcherIssueWorkflowResultEntity &&
          result.requiresRefresh &&
          context.mounted) {
        context
            .read<DispatcherSupportViewModel>()
            .doIntent(const LoadDispatcherSupportEvent());
      }
    }
  }

  Future<void> _handleAssignDriver(
    BuildContext context,
    DispatcherSupportIssueEntity issue,
  ) async {
    if (onAssignAlternativeDriver != null) {
      onAssignAlternativeDriver!(issue);
    } else {
      final result = await context.pushNamed(
        AppRoutes.dispatcherReassignDriver,
        arguments: DispatcherReassignDriverRouteArgs(issueId: issue.id),
      );
      if (result is ReassignmentResultEntity && context.mounted) {
        context
            .read<DispatcherSupportViewModel>()
            .doIntent(const LoadDispatcherSupportEvent());
      }
    }
  }
}

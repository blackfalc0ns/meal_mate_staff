import 'package:flutter/material.dart';

import '../../../../../../config/routing/app_routes.dart';
import '../../../../../../config/routing/arguments/dispatcher_support_route_arguments.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_support_issue_entity.dart';
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
            child: DispatcherSupportIssueCard(
              key: ValueKey(issue.id),
              issue: issue,
              onTap: () => _handleViewDetails(context, issue),
              onViewDetails: () => _handleViewDetails(context, issue),
              onAssignAlternativeDriver: () =>
                  _handleAssignDriver(context, issue),
            ),
          );
        },
        childCount: issues.length,
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<String>) {
            final index = issues.indexWhere((i) => i.id == key.value);
            return index == -1 ? null : index;
          }
          return null;
        },
      ),
    );
  }

  void _handleViewDetails(
    BuildContext context,
    DispatcherSupportIssueEntity issue,
  ) {
    if (onViewDetails != null) {
      onViewDetails!(issue);
    } else {
      context.pushNamed(
        AppRoutes.dispatcherSupportIssueDetails,
        arguments: DispatcherSupportIssueDetailsRouteArgs(issueId: issue.id),
      );
    }
  }

  void _handleAssignDriver(
    BuildContext context,
    DispatcherSupportIssueEntity issue,
  ) {
    if (onAssignAlternativeDriver != null) {
      onAssignAlternativeDriver!(issue);
    } else {
      context.pushNamed(AppRoutes.assignBox);
    }
  }
}

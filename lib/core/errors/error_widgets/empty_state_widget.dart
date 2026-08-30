import 'package:flutter/material.dart';

import 'base_error_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.title = 'No data found',
    this.description = 'There is nothing to show right now.',
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return BaseErrorWidget(
      title: title,
      description: description,
      icon: icon,
      onRetry: onAction,
      retryText: actionText ?? 'Refresh',
    );
  }
}

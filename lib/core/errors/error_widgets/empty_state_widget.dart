import 'package:flutter/material.dart';

import '../../extensions/extensions.dart';
import 'base_error_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  final String? title;
  final String? description;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    return BaseErrorWidget(
      title: title ?? l10n.emptyNoDataTitle,
      description: description ?? l10n.emptyNoDataDesc,
      icon: icon,
      onRetry: onAction,
      retryText: actionText ?? l10n.refresh,
    );
  }
}

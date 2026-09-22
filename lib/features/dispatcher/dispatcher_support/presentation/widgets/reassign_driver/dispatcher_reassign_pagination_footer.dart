import 'package:flutter/material.dart';

import '../../../../../../config/theme/spacing.dart';
import '../../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../../core/network/failures.dart';

class DispatcherReassignPaginationFooter extends StatelessWidget {
  const DispatcherReassignPaginationFooter({
    super.key,
    required this.isLoading,
    this.failure,
    this.onRetry,
  });

  final bool isLoading;
  final Failure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: Spacing.md),
        child: Center(
          child: SizedBox(
            width: Spacing.iconMd,
            height: Spacing.iconMd,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (failure != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: InlineApiErrorWidget(
          failure: failure!,
          onRetry: onRetry,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

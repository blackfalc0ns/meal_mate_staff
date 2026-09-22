import 'package:flutter/material.dart';
import '../../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../../core/extensions/extensions.dart';

class DispatcherSupportEmptyState extends StatelessWidget {
  const DispatcherSupportEmptyState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: EmptyStateWidget(
          title: locale.supportEmptyTitle,
          description: locale.supportEmptyDescription,
          icon: Icons.support_agent_rounded,
          onAction: onRetry,
          actionText: isArabic ? 'إعادة المحاولة' : 'Refresh',
        ),
      ),
    );
  }
}

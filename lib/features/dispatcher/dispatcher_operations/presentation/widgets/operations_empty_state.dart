import 'package:flutter/material.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';

class OperationsEmptyState extends StatelessWidget {
  const OperationsEmptyState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: EmptyStateWidget(
          title: isArabic ? 'لا توجد عمليات' : 'No Operations Found',
          description: isArabic
              ? 'لم يتم العثور على أي عمليات تطابق معايير البحث أو التصفية المحددة'
              : 'No operations match the selected search or filter criteria.',
          icon: Icons.assignment_outlined,
          onAction: onRetry,
          actionText: isArabic ? 'تحديث' : 'Refresh',
        ),
      ),
    );
  }
}

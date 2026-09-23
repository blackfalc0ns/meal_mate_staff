import 'package:flutter/material.dart';

import '../../../../../core/errors/error_widgets/empty_state_widget.dart';

class DispatcherDriversEmptyState extends StatelessWidget {
  const DispatcherDriversEmptyState({super.key, this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: EmptyStateWidget(
          title: isArabic ? 'لا يوجد سائقون' : 'No Drivers Found',
          description: isArabic
              ? 'لا يوجد سائقون متاحون حالياً في هذه المنطقة أو القائمة'
              : 'There are currently no drivers in this area or view.',
          icon: Icons.people_outline_rounded,
          onAction: onRefresh,
          actionText: isArabic ? 'تحديث' : 'Refresh',
        ),
      ),
    );
  }
}

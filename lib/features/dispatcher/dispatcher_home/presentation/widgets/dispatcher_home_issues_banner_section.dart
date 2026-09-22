import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_alert_entity.dart';
import 'dispatcher_home_alert_banner.dart';

class DispatcherHomeIssuesBannerSection extends StatelessWidget {
  const DispatcherHomeIssuesBannerSection({
    super.key,
    required this.activeIssues,
  });

  final DispatcherHomeActiveIssuesEntity activeIssues;

  @override
  Widget build(BuildContext context) {
    if (activeIssues.count <= 0) return const SizedBox.shrink();

    final locale = context.localization;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final description = isArabic
        ? (activeIssues.summaryAr.isNotEmpty
            ? activeIssues.summaryAr
            : activeIssues.summaryEn)
        : (activeIssues.summaryEn.isNotEmpty
            ? activeIssues.summaryEn
            : activeIssues.summaryAr);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: Spacing.lg),
        DispatcherHomeAlertBanner(
          alert: DispatcherHomeAlertEntity(
            id: 'active-issues',
            title: locale.homeAlertActiveIssues(activeIssues.count),
            description: description,
          ),
          onTap: () => context.pushNamed(AppRoutes.dispatcherSupport),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/entities/dispatcher_home_overview_entity.dart';
import 'dispatcher_home_header.dart';

class DispatcherHomeHeaderSection extends StatelessWidget {
  const DispatcherHomeHeaderSection({
    super.key,
    required this.overview,
  });

  final DispatcherHomeOverviewEntity overview;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final restaurantName = isArabic
        ? (overview.restaurant.nameAr.isNotEmpty
            ? overview.restaurant.nameAr
            : overview.restaurant.nameEn)
        : (overview.restaurant.nameEn.isNotEmpty
            ? overview.restaurant.nameEn
            : overview.restaurant.nameAr);

    return DispatcherHomeHeader(
      restaurantName: restaurantName,
      role: overview.restaurant.role,
      greeting: overview.greeting.title,
      greetingSubtitle: overview.greeting.subtitle,
      hasUnreadNotifications: overview.activeIssues.count > 0,
    );
  }
}

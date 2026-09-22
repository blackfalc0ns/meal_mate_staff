import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_area_summary_entity.dart';
import 'dispatcher_home_areas_card.dart';

class DispatcherHomeAreasSection extends StatelessWidget {
  const DispatcherHomeAreasSection({
    super.key,
    required this.regions,
  });

  final List<DispatcherHomeAreaSummaryEntity> regions;

  @override
  Widget build(BuildContext context) {
    return DispatcherHomeAreasCard(
      areas: regions.take(4).toList(growable: false),
      onViewAll: () => context.pushNamed(AppRoutes.dispatcherOperations),
      onAreaTap: (_) => context.pushNamed(AppRoutes.dispatcherOperations),
    );
  }
}

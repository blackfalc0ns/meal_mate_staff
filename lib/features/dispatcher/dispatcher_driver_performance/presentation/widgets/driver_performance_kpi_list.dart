import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/driver_performance_kpi_entity.dart';
import 'driver_performance_kpi_card.dart';

class DriverPerformanceKpiList extends StatelessWidget {
  const DriverPerformanceKpiList({
    super.key,
    required this.items,
  });

  final List<DriverPerformanceKpiEntity> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsetsDirectional.only(end: Spacing.sm),
                child: DriverPerformanceKpiCard(item: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

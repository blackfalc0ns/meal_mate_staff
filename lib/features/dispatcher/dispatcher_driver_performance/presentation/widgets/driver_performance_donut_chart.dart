import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_distribution_item_entity.dart';
import 'driver_performance_donut_painter.dart';

class DriverPerformanceDonutChart extends StatelessWidget {
  const DriverPerformanceDonutChart({
    super.key,
    required this.items,
    required this.centerValue,
    required this.centerLabel,
    this.size = 105,
  });

  final List<DriverPerformanceDistributionItemEntity> items;
  final String centerValue;
  final String centerLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: DriverPerformanceDonutPainter(
              items: items,
              colorScheme: color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size16,
                  color: color.onSurface,
                ),
              ),
              Text(
                centerLabel,
                style: getRegularStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size9,
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../domain/entities/driver_performance_comparison_entity.dart';

class DriverComparisonDriverHeader extends StatelessWidget {
  const DriverComparisonDriverHeader({
    super.key,
    required this.driver,
    this.width = 130,
  });

  final DriverComparisonRecordEntity driver;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SizedBox(
      width: width,
      height: 96,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.surfaceContainerHighest,
              border: Border.all(
                color: color.primary.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: AppCachedNetworkImage(
                imageUrl: driver.avatarUrl,
                width: 44,
                height: 44,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            driver.fullName,
            style: getBoldStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size11,
              color: color.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            driver.driverCode,
            style: getRegularStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size9,
              color: color.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

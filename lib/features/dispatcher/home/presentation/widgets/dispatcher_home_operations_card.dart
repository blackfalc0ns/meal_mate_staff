import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_operations_status_entity.dart';

class DispatcherHomeOperationsCard extends StatelessWidget {
  const DispatcherHomeOperationsCard({
    super.key,
    required this.operations,
    this.onViewReports,
  });

  final DispatcherHomeOperationsStatusEntity operations;
  final VoidCallback? onViewReports;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.35),
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.homeSoftPurpleBg,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Center(
                  child: Image.asset(
                    AppAssets.dispatcherHomeOperationsHeart,
                    width: 14,
                    height: 14,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  locale.homeOperationsStatusTitle,
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size9,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Center(
            child: SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: CircularProgressIndicator(
                      value: operations.completionRate / 100.0,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: color.homeGaugeTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.homeGaugeProgress,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${operations.completionRate}%',
                        style: getBoldStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size12,
                          color: color.onSurface,
                        ),
                      ),
                      Text(
                        locale.homeCompletionRate,
                        style: getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size7 - 1,
                          color: color.homeMutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _buildBreakdownRow(
            dotColor: color.homeTagDeliveryBg,
            label: operations.deliveredLabel,
            count: operations.deliveredCount,
            color: color,
          ),
          const SizedBox(height: 3),
          _buildBreakdownRow(
            dotColor: color.info,
            label: operations.inDeliveryLabel,
            count: operations.inDeliveryCount,
            color: color,
          ),
          const SizedBox(height: 3),
          _buildBreakdownRow(
            dotColor: color.homeStar,
            label: operations.pendingLabel,
            count: operations.pendingCount,
            color: color,
          ),
          const SizedBox(height: 3),
          _buildBreakdownRow(
            dotColor: color.error,
            label: operations.cancelledLabel,
            count: operations.cancelledCount,
            color: color,
          ),
          const SizedBox(height: Spacing.sm),
          Material(
            color: color.homeSoftPurpleBg,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: InkWell(
              onTap: onViewReports,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              child: Container(
                height: 28,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.dispatcherHomeChartIcon,
                      width: 10,
                      height: 10,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.homeViewReports,
                      style: getBoldStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: FontSize.size7,
                        color: color.homeActionIconPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required Color dotColor,
    required String label,
    required int count,
    required ColorScheme color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(
            label,
            style: getRegularStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size7,
              color: color.homeMutedText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$count',
          style: getBoldStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size9,
            color: color.onSurface,
          ),
        ),
      ],
    );
  }
}

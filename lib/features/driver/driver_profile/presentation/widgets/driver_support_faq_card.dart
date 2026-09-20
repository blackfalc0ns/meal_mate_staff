import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_topic_entity.dart';
import 'driver_support_topic_tile.dart';

class DriverSupportFaqCard extends StatelessWidget {
  const DriverSupportFaqCard({
    super.key,
    required this.topics,
    this.onTopicTap,
    this.onViewAllTap,
  });

  final List<DriverSupportTopicEntity> topics;
  final ValueChanged<DriverSupportTopicEntity>? onTopicTap;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locale.driverSupportFaqTitle,
          style: getBoldStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size16,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.6),
              width: Spacing.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < topics.length; i++)
                DriverSupportTopicTile(
                  topic: topics[i],
                  showDivider: true,
                  onTap: () => onTopicTap?.call(topics[i]),
                ),
              InkWell(
                onTap: onViewAllTap,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(Spacing.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 11,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        locale.driverSupportViewAllTopics,
                        style: getBoldStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size12,
                          color: color.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_topic_entity.dart';

class DriverSupportTopicTile extends StatelessWidget {
  const DriverSupportTopicTile({
    super.key,
    required this.topic,
    this.onTap,
    this.showDivider = true,
  });

  final DriverSupportTopicEntity topic;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Spacing.xs + 2),
                  ),
                  child: Icon(topic.icon, color: color.primary, size: 16),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic.title,
                        style: getBoldStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size10,
                          color: color.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic.subtitle,
                        style: getRegularStyle(
                          fontFamily: FontConstant.alexandria,
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: color.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              indent: Spacing.sm,
              endIndent: Spacing.sm,
              color: color.outlineVariant.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }
}

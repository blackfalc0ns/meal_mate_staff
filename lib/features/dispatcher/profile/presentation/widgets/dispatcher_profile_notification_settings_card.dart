import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_notification_setting_entity.dart';

class DispatcherProfileNotificationSettingsCard extends StatelessWidget {
  const DispatcherProfileNotificationSettingsCard({
    super.key,
    required this.settings,
    required this.onSettingChanged,
  });

  final List<DispatcherNotificationSettingEntity> settings;
  final void Function(String id, bool isEnabled) onSettingChanged;

  String _getTitle(BuildContext context, String key) {
    final locale = context.localization;
    switch (key) {
      case 'new_box':
        return locale.profileNotifyNewBoxTitle;
      case 'box_problem':
        return locale.profileNotifyBoxProblemTitle;
      case 'driver_completed':
        return locale.profileNotifyDriverFinishedTitle;
      case 'performance_updates':
        return locale.profileNotifyPerformanceTitle;
      default:
        return key;
    }
  }

  String _getSubtitle(BuildContext context, String key) {
    final locale = context.localization;
    switch (key) {
      case 'new_box':
        return locale.profileNotifyNewBoxSubtitle;
      case 'box_problem':
        return locale.profileNotifyBoxProblemSubtitle;
      case 'driver_completed':
        return locale.profileNotifyDriverFinishedSubtitle;
      case 'performance_updates':
        return locale.profileNotifyPerformanceSubtitle;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_rounded,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.profileNotificationSettings,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.4),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settings.length,
            separatorBuilder: (_, _) => Divider(
              height: Spacing.border,
              thickness: Spacing.border,
              color: color.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final item = settings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: Spacing.dispatcherActionBtnSmallHeight,
                      height: Spacing.dispatcherActionBtnSmallHeight,
                      decoration: BoxDecoration(
                        color: color.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Spacing.radiusXs * 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        color: color.primary,
                        size: Spacing.iconSm,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitle(context, item.titleKey),
                            style: getBoldStyle(
                              fontSize: FontSize.size12,
                              color: color.onSurface,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs / 2),
                          Text(
                            _getSubtitle(context, item.subtitleKey),
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: item.isEnabled,
                      activeThumbColor: color.primary,
                      activeTrackColor: color.primary.withValues(alpha: 0.3),
                      onChanged: (val) => onSettingChanged(item.id, val),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

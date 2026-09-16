import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/dispatcher_notification_entity.dart';
import 'dispatcher_notification_card.dart';

class DispatcherNotificationsList extends StatelessWidget {
  const DispatcherNotificationsList({
    super.key,
    required this.notifications,
    this.onNotificationTap,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<DispatcherNotificationEntity> notifications;
  final ValueChanged<DispatcherNotificationEntity>? onNotificationTap;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const SizedBox(
        height: Spacing.sm - Spacing.border,
      ),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return DispatcherNotificationCard(
          notification: item,
          onTap: () => onNotificationTap?.call(item),
        );
      },
    );
  }
}

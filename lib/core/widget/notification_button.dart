import 'package:flutter/material.dart';

import '../../config/routing/app_routes.dart';
import '../extensions/extensions.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({
    super.key,
    this.onPressed,
    this.hasUnread = false,
    this.unreadCount = 0,
  });

  final VoidCallback? onPressed;
  final bool hasUnread;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final showBadge = hasUnread || unreadCount > 0;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed:
              onPressed ??
              () => context.pushNamed(AppRoutes.dispatcherNotifications),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        if (showBadge)
          PositionedDirectional(
            end: unreadCount > 0 ? 4 : 10,
            top: unreadCount > 0 ? 4 : 10,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: unreadCount > 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        child: Text(
                          unreadCount > 50 ? '50+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.square(dimension: 8),
              ),
            ),
          ),
      ],
    );
  }
}

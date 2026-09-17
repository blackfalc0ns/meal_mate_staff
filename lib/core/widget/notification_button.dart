import 'package:flutter/material.dart';

import '../../config/routing/app_routes.dart';
import '../extensions/extensions.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key, this.onPressed, this.hasUnread = false});

  final VoidCallback? onPressed;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
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
        if (hasUnread)
          PositionedDirectional(
            end: 10,
            top: 10,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: 8),
              ),
            ),
          ),
      ],
    );
  }
}

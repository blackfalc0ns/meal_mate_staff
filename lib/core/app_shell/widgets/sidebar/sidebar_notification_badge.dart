import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../extensions/extensions.dart';

/// Red circular badge widget indicating notification count in sidebar items.
class SidebarNotificationBadge extends StatelessWidget {
  const SidebarNotificationBadge({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    if (count <= 0) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(
        minWidth: Spacing.base,
        minHeight: Spacing.base,
      ),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      decoration: BoxDecoration(
        color: color.error,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: getBoldStyle(
          fontSize: 9,
          color: color.onError,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../domain/entities/sidebar_user_entity.dart';
import '../../../extensions/extensions.dart';
import 'sidebar_user_status_chip.dart';

/// User profile header section shown at the top of the sidebar.
class SidebarUserHeader extends StatelessWidget {
  const SidebarUserHeader({super.key, required this.user});

  final SidebarUserEntity user;

  static const double _avatarSize = 76.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _avatarSize,
            height: _avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.primaryContainer,
            ),
            child: ClipOval(
              child: Image.asset(
                user.avatarAsset,
                width: _avatarSize,
                height: _avatarSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person_rounded,
                  size: Spacing.xxl,
                  color: color.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            user.name,
            style: getBoldStyle(fontSize: 14, color: color.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xs),
          SidebarUserStatusChip(isOnline: user.isOnline),
        ],
      ),
    );
  }
}

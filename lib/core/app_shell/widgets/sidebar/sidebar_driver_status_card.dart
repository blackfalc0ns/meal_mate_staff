import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../domain/entities/sidebar_user_entity.dart';
import '../../../extensions/extensions.dart';

/// Card displayed at the bottom of the sidebar showing the driver's active delivery status.
class SidebarDriverStatusCard extends StatelessWidget {
  const SidebarDriverStatusCard({super.key, required this.user});

  final SidebarUserEntity user;

  static const double _carImageSize = 75.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final title = user.statusTitle.isNotEmpty
        ? user.statusTitle
        : locale.sidebarDriverStatusTitle;

    final statusText = user.statusText.isNotEmpty
        ? user.statusText
        : locale.sidebarDriverOffDuty;

    final subtitle = user.statusSubtitle.isNotEmpty
        ? user.statusSubtitle
        : locale.sidebarDriverStatusSubtitle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.4),
          width: Spacing.hairline,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: getRegularStyle(
                    fontSize: 10,
                    color: color.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: Spacing.sm,
                      height: Spacing.sm,
                      decoration: BoxDecoration(
                        color: color.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      statusText,
                      style: getBoldStyle(fontSize: 11, color: color.primary),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle,
                  style: getRegularStyle(fontSize: 9, color: color.onSurface),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/driver/driver_sidebar_car.png',
            width: _carImageSize,
            height: _carImageSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox(width: _carImageSize, height: _carImageSize),
          ),
        ],
      ),
    );
  }
}

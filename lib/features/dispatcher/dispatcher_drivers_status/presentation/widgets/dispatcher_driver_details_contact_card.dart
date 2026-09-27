import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriverDetailsContactCard extends StatelessWidget {
  const DispatcherDriverDetailsContactCard({
    super.key,
    required this.phoneNumber,
    this.onCall,
    this.onChat,
  });

  final String? phoneNumber;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final hasPhone = phoneNumber != null && phoneNumber!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: Spacing.iconSm,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverDetailsContactInfoTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPhone
                          ? phoneNumber!
                          : locale.driversStatusPhoneNotRegistered,
                      style: getBoldStyle(
                        color: hasPhone
                            ? color.onSurface
                            : color.onSurfaceVariant,
                        fontSize: FontSize.size14,
                      ),
                      textDirection: hasPhone ? TextDirection.ltr : null,
                    ),
                    const SizedBox(height: Spacing.xs / 4),
                    Text(
                      locale.driverDetailsContactSubtitle,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: hasPhone ? onChat : null,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: hasPhone
                        ? color.surfaceContainerHighest
                        : color.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: Spacing.iconSm,
                    color: hasPhone
                        ? color.onSurfaceVariant
                        : color.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs * 1.5),
              InkWell(
                onTap: hasPhone ? onCall : null,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: hasPhone
                        ? color.primary.withValues(alpha: 0.12)
                        : color.onSurfaceVariant.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_rounded,
                    size: Spacing.iconSm,
                    color: hasPhone
                        ? color.primary
                        : color.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

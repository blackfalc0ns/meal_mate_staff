import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/dispatcher_driver_details_entity.dart';

class DispatcherDriverDetailsProfileCard extends StatelessWidget {
  const DispatcherDriverDetailsProfileCard({
    super.key,
    required this.details,
    this.onToggleAvailable,
    this.onCopyCode,
    this.isUpdatingAvailability = false,
  });

  final DispatcherDriverDetailsEntity details;
  final ValueChanged<bool>? onToggleAvailable;
  final VoidCallback? onCopyCode;
  final bool isUpdatingAvailability;

  void _handleCopyCode(BuildContext context) {
    if (onCopyCode != null) {
      onCopyCode!();
      return;
    }
    unawaited(Clipboard.setData(ClipboardData(text: details.code)));
    CustomSnackbar.showSuccess(
      context: context,
      message: context.localization.driverDetailsCopiedToClipboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with online dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.outlineVariant.withValues(alpha: 0.5),
                        width: Spacing.border,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          details.avatarUrl != null &&
                              details.avatarUrl!.isNotEmpty
                          ? (details.avatarUrl!.startsWith('http')
                                ? Image.network(
                                    details.avatarUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.person_rounded,
                                          size: Spacing.iconLg,
                                          color: color.onSurfaceVariant,
                                        ),
                                  )
                                : Image.asset(
                                    details.avatarUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.person_rounded,
                                          size: Spacing.iconLg,
                                          color: color.onSurfaceVariant,
                                        ),
                                  ))
                          : Icon(
                              Icons.person_rounded,
                              size: Spacing.iconLg,
                              color: color.onSurfaceVariant,
                            ),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 0,
                    end: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: details.isOnline
                            ? color.tertiary
                            : color.outline,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.surface,
                          width: Spacing.border * 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.sm),
              // Driver Name, Code & Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      style: getBoldStyle(
                        color: color.onSurface,
                        fontSize: FontSize.size15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          details.code,
                          style: getSemiBoldStyle(
                            color: color.primary,
                            fontSize: FontSize.size12,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs / 2),
                        InkWell(
                          onTap: () => _handleCopyCode(context),
                          borderRadius: BorderRadius.circular(Spacing.radiusXs),
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.xs / 4),
                            child: Icon(
                              Icons.copy_rounded,
                              size: Spacing.iconXs,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    if (details.rating != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: Spacing.iconSm,
                            color: color.secondary,
                          ),
                          const SizedBox(width: Spacing.xs / 4),
                          Text(
                            details.rating!.toStringAsFixed(1),
                            style: getBoldStyle(
                              color: color.onSurface,
                              fontSize: FontSize.size12,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs / 2),
                          Text(
                            locale.driverDetailsReviewsCount(
                              details.reviewCount ?? 0,
                            ),
                            style: getRegularStyle(
                              color: color.onSurfaceVariant,
                              fontSize: FontSize.size11,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        locale.driversStatusNewRating,
                        style: getBoldStyle(
                          color: color.primary,
                          fontSize: FontSize.size12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Switch & Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isUpdatingAvailability)
                    const SizedBox(
                      width: 48,
                      height: 32,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    Transform.scale(
                      scale: 0.85,
                      child: Switch.adaptive(
                        value: details.isAvailable,
                        onChanged: onToggleAvailable,
                        activeThumbColor: color.primary,
                        activeTrackColor: color.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xs * 1.5,
                      vertical: Spacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: (details.isOnline ? color.tertiary : color.outline)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Spacing.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: details.isOnline
                                ? color.tertiary
                                : color.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs / 2),
                        Text(
                          details.isOnline
                              ? locale.driverDetailsConnectedNow
                              : locale.driverDetailsNotConnected,
                          style: getSemiBoldStyle(
                            color: details.isOnline
                                ? color.tertiary
                                : color.outline,
                            fontSize: FontSize.size10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            details.isAvailable
                ? locale.driverDetailsAvailableSubtitle
                : locale.driverDetailsUnavailableSubtitle,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size11,
            ),
          ),
        ],
      ),
    );
  }
}

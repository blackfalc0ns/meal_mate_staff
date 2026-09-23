import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';
import '../../domain/entities/driver_details_status.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverDetailsProfileCard extends StatelessWidget {
  const DriverDetailsProfileCard({super.key, required this.profile});

  final DriverProfileEntity profile;

  static Color parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    final buffer = StringBuffer();
    final clean = hexString.replaceFirst('#', '').trim();
    if (clean.length == 6) buffer.write('ff');
    buffer.write(clean);
    final value = int.tryParse(buffer.toString(), radix: 16);
    return value != null ? Color(value) : fallback;
  }

  static String getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final runes = parts[0].runes.toList();
      return String.fromCharCode(runes.first).toUpperCase();
    }
    final first = String.fromCharCode(parts[0].runes.first).toUpperCase();
    final second = String.fromCharCode(parts[1].runes.first).toUpperCase();
    return '$first$second';
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final defaultStatusColor = switch (profile.status) {
      DriverDetailsStatus.available => color.tertiary,
      DriverDetailsStatus.delivering ||
      DriverDetailsStatus.onDelivery => color.primary,
      DriverDetailsStatus.busy => color.secondary,
      DriverDetailsStatus.inBreak => color.error,
      DriverDetailsStatus.offline => color.outline,
      DriverDetailsStatus.unknown => color.outline,
    };

    final statusColor = parseHexColor(profile.statusDotColor, defaultStatusColor);
    final initials = getInitials(profile.fullName);
    final hasAvatar = profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;
    final lastUpdated = profile.lastUpdatedText.isNotEmpty
        ? profile.lastUpdatedText
        : locale.driverDetailsLastUpdatedNow;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Avatar circle with status dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.primary,
                    width: Spacing.border * 2,
                  ),
                ),
                padding: const EdgeInsets.all(Spacing.xs / 2),
                child: ClipOval(
                  child: hasAvatar
                      ? AppCachedNetworkImage(
                          imageUrl: profile.avatarUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorWidget: _buildAvatarFallback(color, initials),
                        )
                      : _buildAvatarFallback(color, initials),
                ),
              ),
              PositionedDirectional(
                bottom: Spacing.zero,
                end: Spacing.zero,
                child: Container(
                  width: Spacing.sm + Spacing.border,
                  height: Spacing.sm + Spacing.border,
                  decoration: BoxDecoration(
                    color: statusColor,
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
          // 2. Driver info text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.fullName.isNotEmpty ? profile.fullName : profile.driverCode,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  profile.driverCode,
                  style: getSemiBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size13,
                  ),
                ),
                if (profile.phoneNumber != null && profile.phoneNumber!.trim().isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs / 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.phoneNumber!,
                          style: getMediumStyle(
                            color: color.onSurfaceVariant,
                            fontSize: FontSize.size11,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(width: Spacing.xs / 2),
                        SvgPicture.asset(
                          AppAssets.driverActionCall,
                          width: Spacing.iconXs,
                          height: Spacing.iconXs,
                          colorFilter: ColorFilter.mode(
                            color.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          // 3. Status and live update
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: Spacing.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.statusText.isNotEmpty
                          ? profile.statusText
                          : locale.driverDetailsStatusAvailable,
                      style: getSemiBoldStyle(
                        color: statusColor,
                        fontSize: FontSize.size11,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      width: Spacing.xs * 1.5,
                      height: Spacing.xs * 1.5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xs / 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lastUpdated,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size10,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs / 2),
                  SvgPicture.asset(
                    AppAssets.driverLiveSignal,
                    width: Spacing.iconXs,
                    height: Spacing.iconXs,
                    colorFilter: ColorFilter.mode(
                      statusColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(ColorScheme color, String initials) {
    if (initials.isNotEmpty) {
      return Container(
        color: color.primaryContainer,
        alignment: Alignment.center,
        child: Text(
          initials,
          style: getBoldStyle(
            color: color.primary,
            fontSize: FontSize.size16,
          ),
        ),
      );
    }
    return Container(
      color: color.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: Spacing.iconLg,
        color: color.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../domain/entities/driver_map_navigation_entity.dart';
import '../../domain/entities/driver_map_unavailable_reason.dart';
import 'driver_map_shimmer.dart';

class DriverMapNavigationPanel extends StatelessWidget {
  const DriverMapNavigationPanel({
    super.key,
    this.navigation,
    this.isRefreshing = false,
    this.onNavigatePressed,
  });

  final DriverMapNavigationEntity? navigation;
  final bool isRefreshing;
  final VoidCallback? onNavigatePressed;

  String _formatDistance(BuildContext context, int meters) {
    final l10n = context.localization;
    final km = meters / 1000.0;
    final formatted = km == km.truncateToDouble()
        ? km.toStringAsFixed(0)
        : km.toStringAsFixed(1);
    return '$formatted ${l10n.driverMapKmUnit}';
  }

  String _formatDuration(BuildContext context, int seconds) {
    final l10n = context.localization;
    final minutes = (seconds / 60.0).round();
    return '$minutes ${l10n.driverMapMinuteUnit}';
  }

  String _formatEta(DateTime arrivalAtUtc) {
    final local = arrivalAtUtc.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _resolveReasonText(
    BuildContext context,
    DriverMapUnavailableReason reason,
  ) {
    final l10n = context.localization;
    switch (reason) {
      case DriverMapUnavailableReason.driverLocationMissing:
        return l10n.driverMapReasonDriverLocationMissing;
      case DriverMapUnavailableReason.driverLocationStale:
        return l10n.driverMapReasonDriverLocationStale;
      case DriverMapUnavailableReason.driverLocationInvalid:
        return l10n.driverMapReasonDriverLocationInvalid;
      case DriverMapUnavailableReason.destinationLocationMissing:
        return l10n.driverMapReasonDestinationLocationMissing;
      case DriverMapUnavailableReason.directionsUnavailable:
      case DriverMapUnavailableReason.unknown:
        return l10n.driverMapReasonDirectionsUnavailable;
    }
  }

  Widget _buildNavButton(BuildContext context) {
    final color = context.colorScheme;
    final l10n = context.localization;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onNavigatePressed,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.primary,
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.navigation_rounded,
                size: 14,
                color: color.onPrimary,
              ),
              const SizedBox(width: Spacing.xs),
              Flexible(
                child: Text(
                  l10n.driverMapNavigateAction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getBoldStyle(
                    fontSize: FontSize.size10,
                    color: color.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isRefreshing) {
      return const DriverMapNavigationShimmer();
    }

    final nav = navigation;
    if (nav == null) {
      return const SizedBox.shrink();
    }

    final color = context.colorScheme;
    final l10n = context.localization;

    if (nav.isCompleted) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          border: Border.all(color: color.outline.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: color.tertiary, size: 20),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                l10n.driverMapCompletedTitle,
                style: getMediumStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (nav.isUnavailable && nav.unavailableReason != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          border: Border.all(color: color.secondary.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: color.secondary, size: 20),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                _resolveReasonText(context, nav.unavailableReason!),
                style: getMediumStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurface,
                ),
              ),
            ),
            if (nav.canNavigate && onNavigatePressed != null) ...[
              const SizedBox(width: Spacing.sm),
              _buildNavButton(context),
            ],
          ],
        ),
      );
    }

    if (nav.isReady) {
      final distanceText = nav.distanceMeters != null
          ? _formatDistance(context, nav.distanceMeters!)
          : null;
      final durationText = nav.durationSeconds != null
          ? _formatDuration(context, nav.durationSeconds!)
          : null;
      final etaText = nav.estimatedArrivalAtUtc != null
          ? _formatEta(nav.estimatedArrivalAtUtc!)
          : null;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: color.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (distanceText != null) ...[
              Icon(Icons.directions_car_outlined, size: 14, color: color.primary),
              const SizedBox(width: 3),
              Text(
                distanceText,
                style: getBoldStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurface,
                ),
              ),
              const SizedBox(width: Spacing.xs),
            ],
            if (durationText != null) ...[
              Icon(Icons.access_time_rounded, size: 14, color: color.primary),
              const SizedBox(width: 3),
              Text(
                durationText,
                style: getBoldStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurface,
                ),
              ),
            ],
            const Spacer(),
            if (etaText != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.driverMapEstimatedArrival,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      fontSize: FontSize.size9,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    etaText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getBoldStyle(
                      fontSize: FontSize.size11,
                      color: color.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.sm),
            ],
            if (nav.canNavigate && onNavigatePressed != null)
              Flexible(
                fit: FlexFit.loose,
                child: _buildNavButton(context),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

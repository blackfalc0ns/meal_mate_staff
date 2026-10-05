import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverActiveStatusLocationRow extends StatelessWidget {
  const DriverActiveStatusLocationRow({
    super.key,
    required this.location,
    this.statusText,
  });

  final String location;
  final String? statusText;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Right half: Status
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    locale.driverCurrentStatusLabel.replaceAll(':', '').trim(),
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'خارج التوصيل',
                          style: getBoldStyle(
                            fontSize: FontSize.size13,
                            color: color.primary,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText ?? locale.driverStatusInDelivery,
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: color.outlineVariant.withValues(alpha: 0.4),
              thickness: Spacing.hairline,
              width: Spacing.md,
            ),
            // Left half: Location
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          locale.driverCurrentLocationLabel
                              .replaceAll(':', '')
                              .trim(),
                          style: getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          location,
                          style: getBoldStyle(
                            fontSize: FontSize.size11,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.near_me_rounded,
                      color: color.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

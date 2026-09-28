import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_start_work_requirement_entity.dart';

class DriverStartWorkRequirementTile extends StatelessWidget {
  const DriverStartWorkRequirementTile({
    super.key,
    required this.requirement,
    this.onTap,
  });

  final DriverStartWorkRequirementEntity requirement;
  final VoidCallback? onTap;

  static const double _iconBoxSize = 36;
  static const double _iconSize = 18;
  static const double _chevronSize = 14;

  IconData _getIconData(DriverRequirementType type) {
    switch (type) {
      case DriverRequirementType.checklist:
        return Icons.verified_user_outlined;
      case DriverRequirementType.pickup:
        return Icons.location_on_outlined;
      case DriverRequirementType.readiness:
        return Icons.shield_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: color.surface,
      borderRadius: BorderRadius.circular(Spacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(
              color: color.driverCardBorder,
              width: Spacing.hairline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: _iconBoxSize,
                height: _iconBoxSize,
                decoration: BoxDecoration(
                  color: color.driverLocationBg,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  _getIconData(requirement.type),
                  color: color.primary,
                  size: _iconSize,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      requirement.title,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      requirement.subtitle,
                      style: getRegularStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.onSurfaceVariant,
                size: _chevronSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverMapStopMarkerItem extends StatelessWidget {
  const DriverMapStopMarkerItem({
    super.key,
    required this.boxCode,
    required this.isSelected,
  });

  final String boxCode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final avatarSize = isSelected
        ? Spacing.dispatcherMapMarkerAvatarSize
        : Spacing.buttonSmallHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: color.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? color.primary : color.primaryBorder,
              width: isSelected ? Spacing.border * 2 : Spacing.border,
            ),
            boxShadow: [
              BoxShadow(
                color: color.shadow.withValues(alpha: isSelected ? 0.35 : 0.18),
                blurRadius: isSelected ? Spacing.sm : Spacing.xs,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            AppAssets.driverKpiBox,
            width: isSelected ? Spacing.iconLg : Spacing.iconMd,
            height: isSelected ? Spacing.iconLg : Spacing.iconMd,
            colorFilter: ColorFilter.mode(
              color.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        if (boxCode.isNotEmpty) ...[
          const SizedBox(height: Spacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.border * 2,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color.primary : color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
              border: Border.all(
                color: isSelected ? color.primary : color.primaryBorder,
                width: Spacing.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.shadow.withValues(alpha: 0.2),
                  blurRadius: Spacing.xs,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              boxCode,
              style: getBoldStyle(
                fontSize: FontSize.size9,
                color: isSelected ? color.onPrimary : color.onSurface,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

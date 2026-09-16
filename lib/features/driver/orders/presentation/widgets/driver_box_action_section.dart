import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import 'driver_box_status_pill.dart';

class DriverBoxActionSection extends StatelessWidget {
  const DriverBoxActionSection({
    super.key,
    required this.isLoaded,
    this.onCompleteAction,
  });

  final bool isLoaded;
  final VoidCallback? onCompleteAction;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DriverBoxStatusPill(isLoaded: isLoaded),
        const SizedBox(height: Spacing.xs),
        if (!isLoaded)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCompleteAction,
              borderRadius: BorderRadius.circular(Spacing.radiusXs),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs,
                  vertical: Spacing.hairline * 4,
                ),
                decoration: BoxDecoration(
                  color: color.surface,
                  borderRadius: BorderRadius.circular(Spacing.radiusXs),
                  border: Border.all(
                    color: color.primary.withValues(alpha: 0.3),
                    width: Spacing.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      AppAssets.driverGestureTap,
                      width: Spacing.iconXs,
                      height: Spacing.iconXs,
                      colorFilter: ColorFilter.mode(
                        color.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: Spacing.hairline * 6),
                    Text(
                      locale.driverCompleteAction,
                      style: getMediumStyle(
                        color: color.primary,
                        fontSize: FontSize.size8,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.hairline * 6,
            ),
            decoration: BoxDecoration(
              color: color.tertiaryContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusXs),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: Spacing.iconXs - 2,
                  color: color.tertiary,
                ),
                const SizedBox(width: Spacing.hairline * 4),
                Text(
                  locale.driverStatusLoaded,
                  style: getRegularStyle(
                    color: color.tertiary,
                    fontSize: FontSize.size8,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

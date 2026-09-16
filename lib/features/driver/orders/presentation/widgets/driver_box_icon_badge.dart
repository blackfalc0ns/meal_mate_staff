import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxIconBadge extends StatelessWidget {
  const DriverBoxIconBadge({
    super.key,
    required this.isLoaded,
  });

  final bool isLoaded;

  static const double _width = 46;
  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: isLoaded ? color.tertiaryContainer : color.primaryContainer,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.driverBoxLinear,
            width: Spacing.iconMd,
            height: Spacing.iconMd,
            colorFilter: ColorFilter.mode(
              isLoaded ? color.tertiary : color.primary,
              BlendMode.srcIn,
            ),
          ),
          if (isLoaded)
            PositionedDirectional(
              top: Spacing.xs,
              end: Spacing.xs,
              child: SvgPicture.asset(
                AppAssets.driverCheckFill,
                width: Spacing.iconXs,
                height: Spacing.iconXs,
              ),
            ),
        ],
      ),
    );
  }
}

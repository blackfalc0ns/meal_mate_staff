import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxesFilterActionButton extends StatelessWidget {
  const DriverBoxesFilterActionButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  static const double _buttonDimension = Spacing.dispatcherMapButtonHeight;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: color.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        child: Ink(
          width: _buttonDimension,
          height: _buttonDimension,
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            border: Border.all(
              color: color.outlineVariant,
              width: Spacing.border,
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.driverFilterIcon,
              width: Spacing.iconSm + 2,
              height: Spacing.iconSm + 2,
            ),
          ),
        ),
      ),
    );
  }
}

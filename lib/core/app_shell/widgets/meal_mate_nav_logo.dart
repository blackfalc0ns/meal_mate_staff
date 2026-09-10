import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/spacing.dart';
import '../../constants/assets.dart';
import '../../extensions/extensions.dart';

class MealMateNavLogo extends StatelessWidget {
  const MealMateNavLogo({
    super.key,
    required this.isSelected,
    this.size = Spacing.iconMd,
  });

  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return SvgPicture.asset(
      AppAssets.navHome,
      width: size,
      height: size,
      colorFilter: isSelected
          ? null
          : ColorFilter.mode(
              color.onSurface,
              BlendMode.srcIn,
            ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_cached_network_image.dart';

class AssignBoxDriverAvatar extends StatelessWidget {
  const AssignBoxDriverAvatar({
    super.key,
    this.avatarUrl,
    this.badgeNumber,
    this.size = Spacing.buttonSmallHeight,
  });

  final String? avatarUrl;
  final String? badgeNumber;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.surface,
            border: Border.all(color: color.primary, width: Spacing.border),
          ),
          child: AppCachedNetworkImage(
            imageUrl: avatarUrl,
            width: size,
            height: size,
            shape: BoxShape.circle,
            fit: BoxFit.cover,
            errorWidget: Center(
              child: Icon(
                Icons.person_rounded,
                size: Spacing.iconMd,
                color: color.primary,
              ),
            ),
            loadingWidget: Center(
              child: Icon(
                Icons.person_rounded,
                size: Spacing.iconMd,
                color: color.primary,
              ),
            ),
          ),
        ),
        if (badgeNumber != null)
          PositionedDirectional(
            bottom: -Spacing.xs,
            start: -Spacing.xs,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.zero,
              ),
              decoration: BoxDecoration(
                color: color.primary,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
              ),
              child: Text(
                badgeNumber!,
                style: getSemiBoldStyle(
                  color: color.onPrimary,
                  fontSize: FontSize.size9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

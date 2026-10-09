import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxesStatsBanner extends StatelessWidget {
  const DriverBoxesStatsBanner({
    super.key,
    this.totalMeals = 32,
    this.totalBoxes = 8,
  });

  final int totalMeals;
  final int totalBoxes;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return Container(
      height: 104,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF261D52),
            Color(0xFF151033),
          ],
        ),
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF603BC1).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: Stack(
          children: [
            // Ambient glow behind illustration
            PositionedDirectional(
              end: -10,
              bottom: -10,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF603BC1).withValues(alpha: 0.35),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF603BC1).withValues(alpha: 0.45),
                      blurRadius: 36,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.md,
              ),
              child: Row(
                children: [
                  // Text stats column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eyebrow label with active indicator dot
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1BC74E),
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                            Flexible(
                              child: Text(
                                locale.driverTotalBoxesToday,
                                style: getMediumStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: FontSize.size12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs),
                        // Number and unit
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$totalBoxes',
                              style: getBoldStyle(
                                color: Colors.white,
                                fontSize: FontSize.size28,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              locale.driverBoxesUnit,
                              style: getMediumStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: FontSize.size13,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  // 3D Box Illustration
                  Image.asset(
                    AppAssets.driverAssignedBoxesBanner,
                    width: 78,
                    height: 74,
                    fit: BoxFit.contain,
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

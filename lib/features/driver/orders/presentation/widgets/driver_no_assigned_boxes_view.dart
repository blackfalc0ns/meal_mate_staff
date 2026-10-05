import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import 'driver_no_assigned_boxes_notice_card.dart';

class DriverNoAssignedBoxesView extends StatelessWidget {
  const DriverNoAssignedBoxesView({
    super.key,
    this.onRefresh,
    this.onBackToHome,
  });

  final VoidCallback? onRefresh;
  final VoidCallback? onBackToHome;

  static const double _illustrationWidth = 240;
  static const double _illustrationHeight = 165;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: Spacing.xxl),
                  Image.asset(
                    AppAssets.driverNoAssignedBoxesIllustration,
                    width: _illustrationWidth,
                    height: _illustrationHeight,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: Spacing.xl),
                  Text(
                    locale.driverNoAssignedBoxesTitle,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    locale.driverNoAssignedBoxesSubtitle,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xxl),
                  const DriverNoAssignedBoxesNoticeCard(),
                  const SizedBox(height: Spacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: Spacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: onRefresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.primary,
                        foregroundColor: color.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Spacing.buttonRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        locale.refresh,
                        style: getSemiBoldStyle(
                          color: color.onPrimary,
                          fontSize: FontSize.size16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextButton(
                    onPressed: onBackToHome,
                    child: Text(
                      locale.driverNoAssignedBoxesBackToHome,
                      style: getSemiBoldStyle(
                        color: color.primary,
                        fontSize: FontSize.size14,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.bottomNavHeight + Spacing.md),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

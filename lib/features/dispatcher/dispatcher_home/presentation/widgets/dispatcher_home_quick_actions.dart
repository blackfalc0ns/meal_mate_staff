import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_home_quick_action_entity.dart';

class DispatcherHomeQuickActions extends StatelessWidget {
  const DispatcherHomeQuickActions({
    super.key,
    required this.actions,
    this.onActionTap,
  });

  final List<DispatcherHomeQuickActionEntity> actions;
  final ValueChanged<DispatcherHomeQuickActionType>? onActionTap;

  Color _getBackgroundColor(
    ColorScheme color,
    DispatcherHomeQuickActionType type,
  ) {
    switch (type) {
      case DispatcherHomeQuickActionType.assignDriver:
        return color.homeActionAssignBg;
      case DispatcherHomeQuickActionType.solveIssues:
        return color.homeActionSolveBg;
      case DispatcherHomeQuickActionType.driversMap:
        return color.homeActionMapBg;
      case DispatcherHomeQuickActionType.allDrivers:
        return color.homeActionAllBg;
    }
  }

  Color _getTextColor(
    ColorScheme color,
    DispatcherHomeQuickActionType type,
  ) {
    switch (type) {
      case DispatcherHomeQuickActionType.assignDriver:
        return color.homeActionIconPurple;
      case DispatcherHomeQuickActionType.solveIssues:
      case DispatcherHomeQuickActionType.driversMap:
      case DispatcherHomeQuickActionType.allDrivers:
        return color.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          locale.homeSectionQuickActions,
          style: getSemiBoldStyle(
            fontFamily: FontConstant.alexandria,
            fontSize: FontSize.size12,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: actions.map((action) {
            final bgColor = _getBackgroundColor(color, action.type);
            final textColor = _getTextColor(color, action.type);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
                child: Material(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  child: InkWell(
                    onTap: () => onActionTap?.call(action.type),
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    child: Container(
                      height: 62,
                      padding: const EdgeInsets.symmetric(
                        vertical: Spacing.xs,
                        horizontal: Spacing.xs / 2,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            action.iconAsset,
                            width: Spacing.iconSm + 3,
                            height: Spacing.iconSm + 3,
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            action.title,
                            style: getBoldStyle(
                              fontFamily: FontConstant.alexandria,
                              fontSize: FontSize.size8,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../config/theme/font_manager.dart';
import '../../extensions/extensions.dart';

class AppBottomNavItem extends StatelessWidget {
  const AppBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.activeBackground,
  });

  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeBackground;

  static const Color defaultInactiveColor = Color(0xFF191C1D);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final effectiveActiveBg = activeBackground ?? color.primary;
    final effectiveInactiveColor = inactiveColor ?? defaultInactiveColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? effectiveActiveBg
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: effectiveActiveBg.withValues(alpha: 0.35),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 34,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 24,
                        child: icon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontConstant.alexandria,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? color.onPrimary
                            : effectiveInactiveColor,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

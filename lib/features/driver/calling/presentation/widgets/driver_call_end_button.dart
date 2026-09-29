import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverCallEndButton extends StatelessWidget {
  const DriverCallEndButton({
    super.key,
    required this.onEndCall,
  });

  final VoidCallback onEndCall;

  static const double _buttonSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onEndCall,
      borderRadius: BorderRadius.circular(Spacing.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: _buttonSize,
              height: _buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.error,
                boxShadow: [
                  BoxShadow(
                    color: color.error.withValues(alpha: 0.35),
                    blurRadius: Spacing.md,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.call_end_rounded,
                  size: Spacing.iconLg,
                  color: color.onError,
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              locale.driverCallEnd,
              style: getMediumStyle(
                fontSize: FontSize.size12,
                color: color.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class ReturnBoxActions extends StatelessWidget {
  const ReturnBoxActions({
    super.key,
    required this.onConfirmReturn,
    this.isLoading = false,
  });

  final VoidCallback onConfirmReturn;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SizedBox(
      width: double.infinity,
      height: Spacing.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onConfirmReturn,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.primary,
          foregroundColor: color.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.buttonRadius),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(color.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: Spacing.iconMd,
                    color: color.onPrimary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Flexible(
                    child: Text(
                      locale.driverConfirmRestaurantReturnAction,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size16,
                        color: color.onPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

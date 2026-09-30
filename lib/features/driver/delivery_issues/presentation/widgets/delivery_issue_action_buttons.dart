import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliveryIssueActionButtons extends StatelessWidget {
  const DeliveryIssueActionButtons({
    super.key,
    required this.onSubmit,
    required this.onRequestReassign,
    required this.onCallSupervisor,
    this.isLoading = false,
  });

  final VoidCallback onSubmit;
  final VoidCallback onRequestReassign;
  final VoidCallback onCallSupervisor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: Spacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onSubmit,
            icon: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.onPrimary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.near_me_rounded,
                    size: Spacing.iconSm,
                    color: color.onPrimary,
                  ),
            label: Text(
              locale.reportIssueSendToSupervisor,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.primary,
              foregroundColor: color.onPrimary,
              elevation: Spacing.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          height: Spacing.buttonHeight,
          child: OutlinedButton(
            onPressed: onRequestReassign,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: color.primary,
                width: Spacing.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
              ),
            ),
            child: Text(
              locale.reportIssueRequestReassign,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        TextButton.icon(
          onPressed: onCallSupervisor,
          icon: Icon(
            Icons.phone_outlined,
            size: Spacing.iconSm,
            color: color.primary,
          ),
          label: Text(
            locale.reportIssueCallSupervisor,
            style: getMediumStyle(
              fontSize: FontSize.size14,
              color: color.primary,
            ),
          ),
        ),
      ],
    );
  }
}

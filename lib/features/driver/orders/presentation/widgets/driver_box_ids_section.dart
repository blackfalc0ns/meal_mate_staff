import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';

class DriverBoxIdsSection extends StatelessWidget {
  const DriverBoxIdsSection({
    super.key,
    required this.boxId,
    required this.orderCode,
  });

  final String boxId;
  final String orderCode;

  void _handleCopy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: boxId));
    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message: locale.driverBoxCopiedToClipboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          boxId,
          style: getBoldStyle(
            color: color.onSurface,
            fontSize: FontSize.size13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xs),
        InkWell(
          onTap: () => _handleCopy(context),
          borderRadius: BorderRadius.circular(Spacing.radiusXs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.copy_rounded,
                size: Spacing.iconXs,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Flexible(
                child: Text(
                  orderCode,
                  style: getMediumStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

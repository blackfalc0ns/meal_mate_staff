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
    this.boxCode,
    this.boxId,
    this.orderCode,
  });

  final String? boxCode;
  final String? boxId;
  final String? orderCode;

  String get effectiveBoxCode {
    if (boxCode != null && boxCode!.trim().isNotEmpty) {
      return boxCode!;
    }
    if (orderCode != null && orderCode!.trim().isNotEmpty) {
      return orderCode!;
    }
    return boxId ?? '';
  }

  Future<void> _handleCopy(BuildContext context) async {
    final code = effectiveBoxCode;
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    final locale = context.localization;
    CustomSnackbar.showSuccess(
      context: context,
      message: locale.driverBoxCopiedToClipboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final code = effectiveBoxCode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _handleCopy(context),
          borderRadius: BorderRadius.circular(Spacing.radiusXs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  code,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.copy_rounded,
                size: Spacing.iconXs,
                color: color.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

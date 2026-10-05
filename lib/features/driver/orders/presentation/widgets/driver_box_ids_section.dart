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
    this.customerName,
  });

  final String? boxCode;
  final String? boxId;
  final String? orderCode;
  final String? customerName;

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
    final hasCustomer = customerName != null && customerName!.trim().isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCustomer) ...[
          Text(
            customerName!.trim(),
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.border * 2),
        ],
        InkWell(
          onTap: () => _handleCopy(context),
          borderRadius: BorderRadius.circular(Spacing.radiusXs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  code,
                  style: hasCustomer
                      ? getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size10,
                        )
                      : getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size11,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(Icons.copy_rounded, size: 11, color: color.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }
}

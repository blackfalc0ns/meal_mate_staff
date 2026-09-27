import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_document_entity.dart';

class DispatcherDriverDetailsDocumentItem extends StatelessWidget {
  const DispatcherDriverDetailsDocumentItem({
    super.key,
    required this.document,
    this.onTap,
  });

  final DispatcherDriverDocumentEntity document;
  final VoidCallback? onTap;

  String _getDocumentTitle(
    BuildContext context,
    DispatcherDriverDocumentType type,
  ) {
    final locale = context.localization;
    return switch (type) {
      DispatcherDriverDocumentType.drivingLicense =>
        locale.driverDetailsDrivingLicense,
      DispatcherDriverDocumentType.vehicleRegistration =>
        locale.driverDetailsVehicleRegistration,
      DispatcherDriverDocumentType.insurance =>
        locale.driverDetailsInsurance,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final title = _getDocumentTitle(context, document.type);
    final statusText = document.validUntil != null
        ? locale.driverDetailsValidUntil(document.validUntil!)
        : locale.driverDetailsValid;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs * 1.5,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.5),
            width: Spacing.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: Spacing.iconXs * 0.7,
                  color: color.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs / 2),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: Spacing.iconXs,
                  color: color.tertiary,
                ),
                const SizedBox(width: Spacing.xs / 4),
                Expanded(
                  child: Text(
                    statusText,
                    style: getRegularStyle(
                      color: color.tertiary,
                      fontSize: FontSize.size10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

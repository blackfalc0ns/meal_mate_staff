import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_active_box_entity.dart';

class DriverDetailsBoxItem extends StatelessWidget {
  const DriverDetailsBoxItem({super.key, required this.box, this.onTap});

  final DriverActiveBoxEntity box;
  final VoidCallback? onTap;

  static Color parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    final buffer = StringBuffer();
    final clean = hexString.replaceFirst('#', '').trim();
    if (clean.length == 6) buffer.write('ff');
    buffer.write(clean);
    final value = int.tryParse(buffer.toString(), radix: 16);
    return value != null ? Color(value) : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final badgeColor = parseHexColor(box.statusColor, color.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(
            color: color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        child: Row(
          children: [
            // 1. 3D Box image container
            Container(
              width: Spacing.xxl + Spacing.sm,
              height: Spacing.xxl + Spacing.sm,
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: color.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
              ),
              child: Image.asset(AppAssets.driverBox3d, fit: BoxFit.contain),
            ),
            const SizedBox(width: Spacing.sm),
            // 2. Box details & Customer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    box.boxCode.isNotEmpty ? box.boxCode : box.boxId,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size13,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: Spacing.xs / 2),
                  Text(
                    locale.driverDetailsClient(box.customerName),
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AppAssets.driverLocationPin,
                        width: Spacing.xs * 2,
                        height: Spacing.xs * 2,
                        colorFilter: ColorFilter.mode(
                          color.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs / 2),
                      Flexible(
                        child: Text(
                          box.deliveryAddress,
                          style: getRegularStyle(
                            color: color.onSurfaceVariant,
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
            const SizedBox(width: Spacing.xs),
            // 3. Status badge & delivery time
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: Spacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Spacing.radiusXs),
                      ),
                      child: Text(
                        box.statusText,
                        style: getSemiBoldStyle(
                          color: badgeColor,
                          fontSize: FontSize.size10,
                        ),
                      ),
                    ),
                    if (box.scheduledTimeText.isNotEmpty) ...[
                      const SizedBox(height: Spacing.xs / 2),
                      Text(
                        locale.driverDetailsAppointment,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size10,
                        ),
                      ),
                      Text(
                        box.scheduledTimeText,
                        style: getSemiBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size11,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: Spacing.xs),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: Spacing.iconXs,
                    color: color.onSurfaceVariant,
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../domain/entities/driver_box_delivery_status.dart';
import 'driver_box_status_pill.dart';

class DriverBoxActionSection extends StatelessWidget {
  const DriverBoxActionSection({
    super.key,
    this.status = DriverBoxDeliveryStatus.pendingScan,
    this.onCompleteAction,
  });

  final DriverBoxDeliveryStatus status;
  final VoidCallback? onCompleteAction;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverBoxStatusPill(status: status),
        const SizedBox(height: Spacing.sm),
        _buildActionButton(context, color, locale),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ColorScheme color,
    dynamic locale,
  ) {
    switch (status) {
      case DriverBoxDeliveryStatus.pendingScan:
      case DriverBoxDeliveryStatus.barcodeValidated:
      case DriverBoxDeliveryStatus.photoUploaded:
        return AppButton(
          text: locale.driverCompleteAction,
          onPressed: onCompleteAction,
          variant: AppButtonVariant.outlined,
          isExpanded: false,
          height: Spacing.dispatcherActionBtnSmallHeight,
          borderRadius: Spacing.radiusSm,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.hairline * 2,
          ),
          color: color.primary,
          textColor: color.primary,
          textStyle: getBoldStyle(
            color: color.primary,
            fontSize: FontSize.size10,
            height: 1.1,
          ),
          iconWidget: SvgPicture.asset(
            AppAssets.driverGestureTap,
            width: Spacing.iconSm,
            height: Spacing.iconSm,
            colorFilter: ColorFilter.mode(color.primary, BlendMode.srcIn),
          ),
          iconGap: Spacing.xs,
        );

      case DriverBoxDeliveryStatus.pickedUp:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.tertiaryContainer,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: Spacing.iconSm,
                color: color.tertiary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverStatusLoaded,
                style: getBoldStyle(
                  color: color.tertiary,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
        );
    }
  }
}

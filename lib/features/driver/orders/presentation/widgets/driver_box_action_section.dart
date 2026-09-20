import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/l10n/translations/app_localizations.dart';
import '../../../../../core/widget/app_button.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/driver_box_delivery_status.dart';
import 'driver_box_status_pill.dart';

class DriverBoxActionSection extends StatelessWidget {
  const DriverBoxActionSection({
    super.key,
    this.status = DriverBoxDeliveryStatus.ready,
    this.isLoaded,
    this.onCompleteAction,
  });

  final DriverBoxDeliveryStatus status;
  final bool? isLoaded;
  final VoidCallback? onCompleteAction;

  void _handleTap(
    BuildContext context,
    DriverBoxDeliveryStatus currentStatus,
    AppLocalizations locale,
  ) {
    onCompleteAction?.call();
    final message = currentStatus == DriverBoxDeliveryStatus.notLoaded
        ? locale.driverCompleteAction.replaceAll('\n', ' ')
        : locale.driverActionStartDelivery;
    CustomSnackbar.showSuccess(context: context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final effectiveStatus = status;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverBoxStatusPill(status: effectiveStatus),
        const SizedBox(height: Spacing.sm),
        _buildActionButton(context, effectiveStatus, color, locale),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    DriverBoxDeliveryStatus currentStatus,
    ColorScheme color,
    AppLocalizations locale,
  ) {
    switch (currentStatus) {
      case DriverBoxDeliveryStatus.notLoaded:
        return AppButton(
          text: locale.driverCompleteAction,
          onPressed: () =>
              _handleTap(context, DriverBoxDeliveryStatus.notLoaded, locale),
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

      case DriverBoxDeliveryStatus.ready:
        return AppButton(
          text: locale.driverActionStartDelivery,
          onPressed: () =>
              _handleTap(context, DriverBoxDeliveryStatus.ready, locale),
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
            fontSize: FontSize.size11,
            height: 1.1,
          ),
          iconWidget: SvgPicture.asset(
            AppAssets.navDelivery,
            width: Spacing.iconSm,
            height: Spacing.iconSm,
            colorFilter: ColorFilter.mode(color.primary, BlendMode.srcIn),
          ),
          iconGap: Spacing.xs,
        );

      case DriverBoxDeliveryStatus.delivered:
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
                locale.driverActionDelivered,
                style: getBoldStyle(
                  color: color.tertiary,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
        );

      case DriverBoxDeliveryStatus.failed:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.errorContainer,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel_rounded,
                size: Spacing.iconSm,
                color: color.error,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverActionDeliveryFailed,
                style: getBoldStyle(
                  color: color.error,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_box_delivery_status.dart';

class DriverBoxIconBadge extends StatelessWidget {
  const DriverBoxIconBadge({
    super.key,
    this.status = DriverBoxDeliveryStatus.pendingScan,
    this.isLoaded,
  });

  final DriverBoxDeliveryStatus status;
  final bool? isLoaded;

  static const double _size = Spacing.buttonHeight;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final isPickedUp =
        (isLoaded ?? false) || status == DriverBoxDeliveryStatus.pickedUp;

    final Color bgColor;
    final Color iconColor;
    Widget? badge;

    if (isPickedUp) {
      bgColor = color.tertiaryContainer;
      iconColor = color.tertiary;
      badge = Container(
        width: Spacing.iconSm,
        height: Spacing.iconSm,
        decoration: BoxDecoration(
          color: color.tertiary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check,
          size: Spacing.iconXs - 3,
          color: color.surface,
        ),
      );
    } else {
      bgColor = color.primaryContainer;
      iconColor = color.primary;
      badge = null;
    }

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(
            AppAssets.driverBoxLinear,
            width: Spacing.registrationDocumentUploadIcon,
            height: Spacing.registrationDocumentUploadIcon,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          if (badge != null)
            PositionedDirectional(
              top: -Spacing.xs,
              start: -Spacing.xs,
              child: badge,
            ),
        ],
      ),
    );
  }
}

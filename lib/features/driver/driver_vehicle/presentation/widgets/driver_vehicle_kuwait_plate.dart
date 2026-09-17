import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverVehicleKuwaitPlate extends StatelessWidget {
  const DriverVehicleKuwaitPlate({
    super.key,
    required this.plateNumber,
    required this.plateLetter,
    required this.plateLetterEn,
  });

  final String plateNumber;
  final String plateLetter;
  final String plateLetterEn;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Center(
      child: Container(
        height: 62,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: Border.all(color: color.onSurface, width: 2),
        ),
        child: Row(
          children: [
            // Start block (Right in RTL): Letter Arabic / English e.g. أ / A
            Container(
              width: 50,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(color: color.onSurface, width: 1.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: 4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plateLetter,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size16,
                    ),
                  ),
                  Text(
                    plateLetterEn,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size14,
                    ),
                  ),
                ],
              ),
            ),
            // Middle block: Numbers e.g. 12345
            Expanded(
              child: Center(
                child: Text(
                  plateNumber,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size26,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // End block (Left in RTL): دولة الكويت / KUWAIT
            Container(
              width: 80,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: color.onSurface, width: 1.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: 4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    locale.driverVehicleKuwaitState,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size9,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locale.driverVehicleKuwaitEn,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size9,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

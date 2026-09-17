import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/app_button.dart';
import '../../domain/entities/driver_vehicle_entity.dart';
import '../../domain/fake_data/driver_vehicle_fake_data.dart';
import '../widgets/driver_vehicle_header.dart';
import '../widgets/driver_vehicle_license_card.dart';
import '../widgets/driver_vehicle_notice_card.dart';
import '../widgets/driver_vehicle_overview_card.dart';

class DriverVehicleDetailsScreen extends StatelessWidget {
  const DriverVehicleDetailsScreen({
    super.key,
    this.vehicle,
    this.onBack,
    this.onEdit,
    this.onChangePhoto,
  });

  final DriverVehicleEntity? vehicle;
  final VoidCallback? onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onChangePhoto;

  void _handleEdit(BuildContext context, DriverVehicleEntity currentVehicle) {
    if (onEdit != null) {
      onEdit!();
      return;
    }
    context.pushNamed(
      AppRoutes.driverEditVehicleDetails,
      arguments: currentVehicle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    final currentVehicle = vehicle ?? DriverVehicleFakeData.defaultVehicle;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverVehicleHeader(
        title: locale.driverVehicleDetailsTitle,
        subtitle: locale.driverVehicleDetailsSubtitle,
        onBack: onBack,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverVehicleOverviewCard(
                vehicle: currentVehicle,
                onChangePhotoTap:
                    onChangePhoto ?? () => _handleEdit(context, currentVehicle),
              ),
              const SizedBox(height: Spacing.base),
              DriverVehicleLicenseCard(vehicle: currentVehicle),
              const SizedBox(height: Spacing.base),
              const DriverVehicleNoticeCard(),
              const SizedBox(height: Spacing.lg),
              AppButton(
                text: locale.driverVehicleEditButton,
                icon: Icons.edit_outlined,
                onPressed: () => _handleEdit(context, currentVehicle),
                color: color.primary,
                textColor: color.onPrimary,
                textStyle: getBoldStyle(
                  color: color.onPrimary,
                  fontSize: FontSize.size14,
                ),
                borderRadius: Spacing.cardRadius,
                height: Spacing.buttonSmallHeight,
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

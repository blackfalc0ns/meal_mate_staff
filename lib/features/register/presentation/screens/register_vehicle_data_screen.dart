import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/widget/app_button.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../../domain/entities/driver_vehicle_color_entity.dart';
import '../../domain/entities/driver_vehicle_model_entity.dart';
import '../../domain/entities/driver_vehicle_type_entity.dart';
import '../../domain/register_vehicle_data.dart';
import '../controllers/register_vehicle_data_form_controller.dart';
import '../widgets/register_vehicle_catalog_shimmer.dart';
import '../widgets/register_vehicle_license_section.dart';
import '../widgets/register_vehicle_ownership_section.dart';
import '../widgets/register_vehicle_specs_section.dart';

class RegisterVehicleDataScreen extends StatefulWidget {
  const RegisterVehicleDataScreen({
    super.key,
    required this.selectedVehicleColor,
    required this.ownsVehicle,
    required this.onColorSelected,
    required this.onOwnsVehicleChanged,
    required this.onContinue,
    this.vehicleTypes = const [],
    this.vehicleColors = const [],
    this.vehicleModels = const [],
    this.isLoadingVehicleTypes = false,
    this.isLoadingVehicleColors = false,
    this.isSearchingVehicleModels = false,
    this.onVehicleModelQueryChanged,
    this.onSearchVehicleModels,
    this.onRetryVehicleCatalog,
    this.onBackPressed,
    this.initialData,
    this.onVehicleDataChanged,
    this.failure,
  });

  final Color selectedVehicleColor;
  final bool ownsVehicle;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<bool> onOwnsVehicleChanged;
  final VoidCallback onContinue;
  final List<DriverVehicleTypeEntity> vehicleTypes;
  final List<DriverVehicleColorEntity> vehicleColors;
  final List<DriverVehicleModelEntity> vehicleModels;
  final bool isLoadingVehicleTypes;
  final bool isLoadingVehicleColors;
  final bool isSearchingVehicleModels;
  final void Function(String search, String? vehicleType)?
  onVehicleModelQueryChanged;
  final void Function(String search, String? vehicleType)?
  onSearchVehicleModels;
  final VoidCallback? onRetryVehicleCatalog;
  final VoidCallback? onBackPressed;
  final RegisterVehicleData? initialData;
  final ValueChanged<RegisterVehicleData>? onVehicleDataChanged;
  final Failure? failure;

  @override
  State<RegisterVehicleDataScreen> createState() =>
      _RegisterVehicleDataScreenState();
}

class _RegisterVehicleDataScreenState extends State<RegisterVehicleDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late final RegisterVehicleDataFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = RegisterVehicleDataFormController(
      initialData: widget.initialData,
      ownsVehicleInitial: widget.ownsVehicle,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formController.resolveInitialTypeLabel(context, widget.vehicleTypes);
  }

  @override
  void didUpdateWidget(covariant RegisterVehicleDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleTypes != widget.vehicleTypes) {
      _formController.didResolveInitialTypeLabel = false;
      _formController.resolveInitialTypeLabel(context, widget.vehicleTypes);
    }
    if (oldWidget.ownsVehicle != widget.ownsVehicle) {
      _formController.ownsVehicle.value = widget.ownsVehicle;
    }
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = _formController.toVehicleData(
      country: widget.initialData?.country ?? '',
    );
    widget.onVehicleDataChanged?.call(data);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegistrationScaffold(
      title: locale.registrationVehicleData,
      currentStep: 2,
      onBackPressed: widget.onBackPressed,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isLoadingVehicleTypes ||
                widget.isLoadingVehicleColors) ...[
              const RegisterVehicleCatalogShimmer(),
              const SizedBox(height: Spacing.md),
            ],
            RegisterVehicleSpecsSection(
              formController: _formController,
              vehicleTypes: widget.vehicleTypes,
              vehicleModels: widget.vehicleModels,
              isSearchingVehicleModels: widget.isSearchingVehicleModels,
              onVehicleModelQueryChanged: widget.onVehicleModelQueryChanged,
              onSearchVehicleModels: widget.onSearchVehicleModels,
            ),
            const SizedBox(height: Spacing.sm),
            RegisterVehicleLicenseSection(formController: _formController),
            const SizedBox(height: Spacing.sm),
            RegisterVehicleOwnershipSection(
              formController: _formController,
              vehicleColors: widget.vehicleColors,
              onColorSelected: widget.onColorSelected,
              onOwnsVehicleChanged: widget.onOwnsVehicleChanged,
            ),
            if (widget.failure != null) ...[
              const SizedBox(height: Spacing.md),
              InlineApiErrorWidget(
                failure: widget.failure!,
                onRetry: widget.onRetryVehicleCatalog,
              ),
            ],
            const SizedBox(height: Spacing.lg),
            AppButton(
              text: locale.registrationContinue,
              onPressed: _handleContinue,
              height: Spacing.registrationButtonHeight,
              borderRadius: Spacing.registrationRadius,
            ),
            const SizedBox(height: Spacing.screenV),
          ],
        ),
      ),
    );
  }
}

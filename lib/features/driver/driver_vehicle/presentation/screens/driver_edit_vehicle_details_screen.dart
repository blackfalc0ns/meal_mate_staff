import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_vehicle_entity.dart';
import '../../domain/fake_data/driver_vehicle_fake_data.dart';
import '../widgets/driver_edit_vehicle_bottom_actions.dart';
import '../widgets/driver_edit_vehicle_photo_card.dart';
import '../widgets/driver_edit_vehicle_text_field.dart';
import '../widgets/driver_vehicle_header.dart';

class DriverEditVehicleDetailsScreen extends StatefulWidget {
  const DriverEditVehicleDetailsScreen({
    super.key,
    this.vehicle,
    this.onBack,
    this.onSaveSuccess,
  });

  final DriverVehicleEntity? vehicle;
  final VoidCallback? onBack;
  final ValueChanged<DriverVehicleEntity>? onSaveSuccess;

  @override
  State<DriverEditVehicleDetailsScreen> createState() =>
      _DriverEditVehicleDetailsScreenState();
}

class _DriverEditVehicleDetailsScreenState
    extends State<DriverEditVehicleDetailsScreen> {
  late final TextEditingController _brandAndModelController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _colorController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseExpiryController;
  late final TextEditingController _notesController;

  late DriverVehicleEntity _currentVehicle;
  bool _isLoading = false;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _currentVehicle = widget.vehicle ?? DriverVehicleFakeData.defaultVehicle;

    _brandAndModelController = TextEditingController(
      text: _currentVehicle.brandAndModel,
    );
    _modelController = TextEditingController(text: _currentVehicle.model);
    _yearController = TextEditingController(
      text: _currentVehicle.manufactureYear,
    );
    _plateController = TextEditingController(
      text: '${_currentVehicle.plateNumber} ${_currentVehicle.plateLetter}',
    );
    _colorController = TextEditingController(text: _currentVehicle.colorName);
    _licenseNumberController = TextEditingController(
      text: _currentVehicle.licenseNumber,
    );
    _licenseExpiryController = TextEditingController(
      text: _currentVehicle.licenseExpiryDate,
    );
    _notesController = TextEditingController(text: _currentVehicle.notes);

    _brandAndModelController.addListener(_onFieldChanged);
    _modelController.addListener(_onFieldChanged);
    _yearController.addListener(_onFieldChanged);
    _plateController.addListener(_onFieldChanged);
    _colorController.addListener(_onFieldChanged);
    _licenseNumberController.addListener(_onFieldChanged);
    _licenseExpiryController.addListener(_onFieldChanged);
    _notesController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _brandAndModelController.removeListener(_onFieldChanged);
    _modelController.removeListener(_onFieldChanged);
    _yearController.removeListener(_onFieldChanged);
    _plateController.removeListener(_onFieldChanged);
    _colorController.removeListener(_onFieldChanged);
    _licenseNumberController.removeListener(_onFieldChanged);
    _licenseExpiryController.removeListener(_onFieldChanged);
    _notesController.removeListener(_onFieldChanged);

    _brandAndModelController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final changed = _hasFormChanges();
    if (changed != _isChanged) {
      setState(() => _isChanged = changed);
    }
  }

  bool _hasFormChanges() {
    final initialPlate =
        '${_currentVehicle.plateNumber} ${_currentVehicle.plateLetter}'.trim();

    return _brandAndModelController.text.trim() !=
            _currentVehicle.brandAndModel ||
        _modelController.text.trim() != _currentVehicle.model ||
        _yearController.text.trim() != _currentVehicle.manufactureYear ||
        _plateController.text.trim() != initialPlate ||
        _colorController.text.trim() != _currentVehicle.colorName ||
        _licenseNumberController.text.trim() != _currentVehicle.licenseNumber ||
        _licenseExpiryController.text.trim() !=
            _currentVehicle.licenseExpiryDate ||
        _notesController.text.trim() != _currentVehicle.notes;
  }

  void _handleSave() {
    if (!_isChanged) return;

    setState(() => _isLoading = true);

    final updated = _currentVehicle.copyWith(
      brandAndModel: _brandAndModelController.text.trim(),
      model: _modelController.text.trim(),
      manufactureYear: _yearController.text.trim(),
      colorName: _colorController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim(),
      licenseExpiryDate: _licenseExpiryController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if (widget.onSaveSuccess != null) {
      widget.onSaveSuccess!(updated);
    }

    final locale = context.localization;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(locale.driverEditVehicleSuccessMessage)),
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverVehicleHeader(
        title: locale.driverEditVehicleDetailsTitle,
        subtitle: locale.driverEditVehicleDetailsSubtitle,
        onBack: widget.onBack,
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
              DriverEditVehiclePhotoCard(
                imageAsset: _currentVehicle.imageAsset,
              ),
              const SizedBox(height: Spacing.base),
              DriverEditVehicleTextField(
                label: locale.driverVehicleTypeLabel,
                controller: _brandAndModelController,
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: Spacing.md),
              DriverEditVehicleTextField(
                label: locale.driverVehicleModelLabel,
                controller: _modelController,
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: Spacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DriverEditVehicleTextField(
                      label: locale.driverVehicleYearLabel,
                      controller: _yearController,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: DriverEditVehicleTextField(
                      label: locale.driverVehiclePlateTitle,
                      controller: _plateController,
                      icon: Icons.badge_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              DriverEditVehicleTextField(
                label: locale.driverEditVehicleColorLabel,
                controller: _colorController,
                icon: Icons.palette_outlined,
              ),
              const SizedBox(height: Spacing.md),
              DriverEditVehicleTextField(
                label: locale.driverVehicleLicenseNumberLabel,
                controller: _licenseNumberController,
                icon: Icons.credit_card_outlined,
              ),
              const SizedBox(height: Spacing.md),
              DriverEditVehicleTextField(
                label: locale.driverVehicleLicenseExpiryLabel,
                controller: _licenseExpiryController,
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: Spacing.md),
              DriverEditVehicleTextField(
                label: locale.driverEditVehicleNotesLabel,
                hintText: locale.driverEditVehicleNotesHint,
                controller: _notesController,
                maxLines: 3,
              ),
              const SizedBox(height: Spacing.lg),
              DriverEditVehicleBottomActions(
                onSave: _handleSave,
                onCancel: () => Navigator.of(context).pop(),
                isLoading: _isLoading,
                isSaveEnabled: _isChanged,
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

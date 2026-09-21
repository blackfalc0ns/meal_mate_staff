import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/widget/app_button.dart';
import '../../../../core/widget/app_wolt_modal_sheet.dart';
import '../../../auth/presentation/widgets/registration_choice_group.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../../domain/entities/driver_vehicle_color_entity.dart';
import '../../domain/entities/driver_vehicle_model_entity.dart';
import '../../domain/entities/driver_vehicle_type_entity.dart';
import '../../domain/register_vehicle_data.dart';
import '../widgets/register_plate_number_field.dart';
import '../widgets/register_vehicle_color_picker.dart';

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
  late final TextEditingController _vehicleTypeController;
  late final TextEditingController _modelController;
  late final TextEditingController _manufactureYearController;
  late final TextEditingController _plateNumberController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseExpiryController;
  late final TextEditingController _vehicleLicenseExpiryController;
  late final TextEditingController _contractExpiryController;
  late final FocusNode _modelFocusNode;
  Timer? _modelSearchDebounce;
  String _selectedVehicleTypeCode = '';
  String? _selectedVehicleModelValue;
  String _selectedColorHex = '';
  bool _didResolveInitialTypeLabel = false;
  bool _isModelQueryPending = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initialData;
    _vehicleTypeController = TextEditingController(text: init?.type ?? '');
    _modelController = TextEditingController(text: init?.model ?? '');
    _manufactureYearController = TextEditingController(
      text: init?.manufactureYear ?? '',
    );
    _plateNumberController = TextEditingController(
      text: init?.plateNumber ?? '',
    );
    _licenseNumberController = TextEditingController(
      text: init?.licenseNumber ?? '',
    );
    _licenseExpiryController = TextEditingController(
      text: init?.licenseExpiry ?? '',
    );
    _vehicleLicenseExpiryController = TextEditingController(
      text: init?.vehicleLicenseExpiry ?? '',
    );
    _contractExpiryController = TextEditingController(
      text: init?.contractExpiry ?? '',
    );
    _modelFocusNode = FocusNode()..addListener(_handleModelFocusChanged);
    _selectedVehicleTypeCode = init?.type.trim() ?? '';
    _selectedVehicleModelValue = init?.model.trim().isNotEmpty == true
        ? init!.model.trim()
        : null;
    _selectedColorHex = canonicalVehicleColorHex(init?.color) ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveInitialTypeLabel();
  }

  @override
  void didUpdateWidget(covariant RegisterVehicleDataScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleTypes != widget.vehicleTypes) {
      _didResolveInitialTypeLabel = false;
      _resolveInitialTypeLabel();
    }
  }

  @override
  void dispose() {
    _modelSearchDebounce?.cancel();
    _modelFocusNode
      ..removeListener(_handleModelFocusChanged)
      ..dispose();
    _vehicleTypeController.dispose();
    _modelController.dispose();
    _manufactureYearController.dispose();
    _plateNumberController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _vehicleLicenseExpiryController.dispose();
    _contractExpiryController.dispose();
    super.dispose();
  }

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _typeLabel(DriverVehicleTypeEntity type) =>
      _isArabic ? type.nameAr : type.nameEn;

  String _modelLabel(DriverVehicleModelEntity model) =>
      _isArabic ? model.fullNameAr : model.fullNameEn;

  void _resolveInitialTypeLabel() {
    if (_didResolveInitialTypeLabel || _selectedVehicleTypeCode.isEmpty) return;
    for (final type in widget.vehicleTypes) {
      if (type.code.trim() == _selectedVehicleTypeCode) {
        _vehicleTypeController.text = _typeLabel(type);
        _didResolveInitialTypeLabel = true;
        return;
      }
    }
  }

  void _handleModelFocusChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickVehicleType() async {
    _modelSearchDebounce?.cancel();
    if (_isModelQueryPending) {
      setState(() => _isModelQueryPending = false);
    }
    final selectableTypes = widget.vehicleTypes
        .where((type) => type.code.trim().isNotEmpty)
        .toList();
    final labels = selectableTypes.map(_typeLabel).toList();
    DriverVehicleTypeEntity? selectedType;
    for (final type in selectableTypes) {
      if (type.code.trim() == _selectedVehicleTypeCode) {
        selectedType = type;
        break;
      }
    }
    final selected = await AppWoltPickerSheet.show(
      context: context,
      title: context.localization.registrationVehicleType,
      items: labels,
      selectedItem: selectedType == null ? null : _typeLabel(selectedType),
      itemLeadingIcon: Icons.directions_car_rounded,
      searchHint: context.localization.registrationVehicleTypeHint,
    );

    if (selected != null && mounted) {
      final selectedIndex = labels.indexOf(selected);
      if (selectedIndex < 0) return;
      _modelSearchDebounce?.cancel();
      setState(() {
        _selectedVehicleTypeCode = selectableTypes[selectedIndex].code.trim();
        _vehicleTypeController.text = selected;
        _modelController.clear();
        _selectedVehicleModelValue = null;
        _isModelQueryPending = false;
      });
      widget.onVehicleModelQueryChanged?.call('', _selectedVehicleTypeCode);
    }
  }

  void _handleModelChanged(String value) {
    _selectedVehicleModelValue = null;
    _modelSearchDebounce?.cancel();
    _isModelQueryPending = true;
    widget.onVehicleModelQueryChanged?.call(
      value,
      _selectedVehicleTypeCode.isEmpty ? null : _selectedVehicleTypeCode,
    );
    _modelSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _isModelQueryPending = false);
      widget.onSearchVehicleModels?.call(
        value,
        _selectedVehicleTypeCode.isEmpty ? null : _selectedVehicleTypeCode,
      );
    });
    setState(() {});
  }

  void _selectModel(DriverVehicleModelEntity model) {
    _modelSearchDebounce?.cancel();
    setState(() {
      _selectedVehicleModelValue = model.value.trim();
      _modelController.text = _modelLabel(model);
      _modelController.selection = TextSelection.collapsed(
        offset: _modelController.text.length,
      );
    });
    _modelFocusNode.unfocus();
  }

  Future<void> _pickManufactureYear() async {
    final now = DateTime.now();
    final currentYear = int.tryParse(_manufactureYearController.text);
    final initialDate = currentYear != null
        ? DateTime(currentYear, 1, 1)
        : DateTime(now.year - 2, 1, 1);

    final selected = await AppWoltPickerSheet.showDatePicker(
      context: context,
      title: context.localization.registrationManufactureYear,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
      initialCalendarViewMode: CalendarDatePicker2Mode.year,
    );

    if (selected != null && mounted) {
      setState(() {
        _manufactureYearController.text = selected.year.toString();
      });
    }
  }

  Future<void> _pickExpiryDate(
    TextEditingController controller,
    String title,
  ) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final parsed = DateTime.tryParse(controller.text.trim());
    final initialDate = parsed != null && !parsed.isBefore(tomorrow)
        ? parsed
        : tomorrow;
    final selected = await AppWoltPickerSheet.showDatePicker(
      context: context,
      title: title,
      initialDate: initialDate,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 100, 12, 31),
    );
    if (selected != null && mounted) {
      setState(() {
        controller.text = DateTime(
          selected.year,
          selected.month,
          selected.day,
        ).toIso8601String();
      });
    }
  }

  void _handleColorSelected(String hex) {
    final canonical = canonicalVehicleColorHex(hex);
    if (canonical == null) return;
    setState(() => _selectedColorHex = canonical);
    widget.onColorSelected(
      Color(0xFF000000 | int.parse(canonical.substring(1), radix: 16)),
    );
  }

  String _isoDateValue(TextEditingController controller) =>
      DateTime.parse(controller.text.trim()).toIso8601String();

  void _handleContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final data = RegisterVehicleData(
      type: _selectedVehicleTypeCode,
      model: _selectedVehicleModelValue ?? _modelController.text.trim(),
      manufactureYear: _manufactureYearController.text.trim(),
      plateNumber: _plateNumberController.text.trim(),
      country: widget.initialData?.country ?? '',
      color: _selectedColorHex,
      isOwned: widget.ownsVehicle,
      licenseNumber: _licenseNumberController.text.trim(),
      licenseExpiry: _isoDateValue(_licenseExpiryController),
      vehicleLicenseExpiry: _isoDateValue(_vehicleLicenseExpiryController),
      contractExpiry: _contractExpiryController.text.trim().isEmpty
          ? null
          : _isoDateValue(_contractExpiryController),
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
              const LinearProgressIndicator(),
              const SizedBox(height: Spacing.md),
            ],
            RegistrationInputField(
              label: locale.registrationVehicleType,
              hint: locale.registrationVehicleTypeHint,
              isPicker: true,
              controller: _vehicleTypeController,
              onTap: _pickVehicleType,
              prefixIcon: Icons.directions_car_rounded,
              showPickerArrow: true,
              validator: (_) =>
                  context.validateRequired(_selectedVehicleTypeCode),
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationVehicleModel,
              hint: locale.registrationVehicleModelHint,
              controller: _modelController,
              focusNode: _modelFocusNode,
              onChanged: _handleModelChanged,
              validator: (v) => context.validateRequired(v),
            ),
            if (widget.isSearchingVehicleModels)
              const Padding(
                padding: EdgeInsets.only(top: Spacing.xs),
                child: LinearProgressIndicator(),
              ),
            if (_modelFocusNode.hasFocus &&
                !_isModelQueryPending &&
                _modelController.text.trim().isNotEmpty &&
                widget.vehicleModels.isNotEmpty)
              Material(
                color: context.colorScheme.surface,
                child: Column(
                  children: widget.vehicleModels
                      .where((model) => model.value.trim().isNotEmpty)
                      .map(
                        (model) => ListTile(
                          dense: true,
                          title: Text(_modelLabel(model)),
                          onTap: () => _selectModel(model),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationManufactureYear,
              hint: locale.registrationManufactureYearHint,
              isPicker: true,
              prefixIcon: Icons.calendar_month_rounded,
              showPickerArrow: false,
              controller: _manufactureYearController,
              onTap: _pickManufactureYear,
              validator: context.validateManufactureYear,
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegisterPlateNumberField(
              locale: locale,
              controller: _plateNumberController,
              validator: (v) => context.validateRequired(v),
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.driverVehicleLicenseNumberLabel,
              hint: locale.driverVehicleLicenseNumberLabel,
              controller: _licenseNumberController,
              validator: (v) => context.validateRequired(v),
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationLicenseExpiry,
              hint: locale.registrationDateHint,
              isPicker: true,
              prefixIcon: Icons.calendar_month_rounded,
              controller: _licenseExpiryController,
              onTap: () => _pickExpiryDate(
                _licenseExpiryController,
                locale.registrationLicenseExpiry,
              ),
              validator: context.validateFutureDate,
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationVehicleLicenseExpiry,
              hint: locale.registrationDateHint,
              isPicker: true,
              prefixIcon: Icons.calendar_month_rounded,
              controller: _vehicleLicenseExpiryController,
              onTap: () => _pickExpiryDate(
                _vehicleLicenseExpiryController,
                locale.registrationVehicleLicenseExpiry,
              ),
              validator: context.validateFutureDate,
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationContractExpiry,
              hint: locale.registrationDateHint,
              isPicker: true,
              prefixIcon: Icons.calendar_month_rounded,
              controller: _contractExpiryController,
              suffixIcon: _contractExpiryController.text.trim().isEmpty
                  ? null
                  : Icons.clear_rounded,
              suffixTooltip: locale.registrationClearContractExpiry,
              onSuffixTap: () {
                setState(_contractExpiryController.clear);
              },
              onTap: () => _pickExpiryDate(
                _contractExpiryController,
                locale.registrationContractExpiry,
              ),
              validator: context.validateOptionalFutureDate,
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            FormField<String>(
              initialValue: _selectedColorHex,
              validator: (_) => context.validateRequired(_selectedColorHex),
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RegisterVehicleColorPicker(
                    colors: widget.vehicleColors,
                    selectedHex: _selectedColorHex,
                    onColorSelected: (hex) {
                      _handleColorSelected(hex);
                      field.didChange(hex);
                    },
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.xs),
                      child: Text(
                        field.errorText!,
                        style: TextStyle(
                          color: context.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xxl),
            RegistrationChoiceGroup(
              label: locale.registrationOwnVehicle,
              firstText: locale.registrationYes,
              secondText: locale.registrationNo,
              firstSelected: widget.ownsVehicle,
              onFirstTap: () => widget.onOwnsVehicleChanged(true),
              onSecondTap: () => widget.onOwnsVehicleChanged(false),
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

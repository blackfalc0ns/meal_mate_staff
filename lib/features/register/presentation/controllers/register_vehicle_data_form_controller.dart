import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_wolt_modal_sheet.dart';
import '../../domain/entities/driver_vehicle_model_entity.dart';
import '../../domain/entities/driver_vehicle_type_entity.dart';
import '../../domain/register_vehicle_data.dart';
import '../widgets/register_vehicle_color_picker.dart';

/// Encapsulates controllers, focus, debouncing, and picker workflows for vehicle registration data.
class RegisterVehicleDataFormController {
  RegisterVehicleDataFormController({
    RegisterVehicleData? initialData,
    bool ownsVehicleInitial = true,
  }) {
    vehicleTypeController = TextEditingController(
      text: initialData?.type ?? '',
    );
    modelController = TextEditingController(text: initialData?.model ?? '');
    manufactureYearController = TextEditingController(
      text: initialData?.manufactureYear ?? '',
    );
    plateNumberController = TextEditingController(
      text: initialData?.plateNumber ?? '',
    );
    licenseNumberController = TextEditingController(
      text: initialData?.licenseNumber ?? '',
    );
    licenseExpiryController = TextEditingController(
      text: initialData?.licenseExpiry ?? '',
    );
    vehicleLicenseExpiryController = TextEditingController(
      text: initialData?.vehicleLicenseExpiry ?? '',
    );
    contractExpiryController = TextEditingController(
      text: initialData?.contractExpiry ?? '',
    );

    selectedVehicleTypeCode = initialData?.type.trim() ?? '';
    selectedVehicleModelValue = initialData?.model.trim().isNotEmpty == true
        ? initialData!.model.trim()
        : null;

    final initialColorHex = canonicalVehicleColorHex(initialData?.color) ?? '';
    selectedColorHex = ValueNotifier<String>(initialColorHex);
    ownsVehicle = ValueNotifier<bool>(ownsVehicleInitial);
    isModelQueryPending = ValueNotifier<bool>(false);

    modelFocusNode = FocusNode();
  }

  late final TextEditingController vehicleTypeController;
  late final TextEditingController modelController;
  late final TextEditingController manufactureYearController;
  late final TextEditingController plateNumberController;
  late final TextEditingController licenseNumberController;
  late final TextEditingController licenseExpiryController;
  late final TextEditingController vehicleLicenseExpiryController;
  late final TextEditingController contractExpiryController;
  late final FocusNode modelFocusNode;

  late final ValueNotifier<String> selectedColorHex;
  late final ValueNotifier<bool> ownsVehicle;
  late final ValueNotifier<bool> isModelQueryPending;

  Timer? _modelSearchDebounce;
  String selectedVehicleTypeCode = '';
  String? selectedVehicleModelValue;
  bool didResolveInitialTypeLabel = false;

  void dispose() {
    _modelSearchDebounce?.cancel();
    modelFocusNode.dispose();
    selectedColorHex.dispose();
    ownsVehicle.dispose();
    isModelQueryPending.dispose();

    vehicleTypeController.dispose();
    modelController.dispose();
    manufactureYearController.dispose();
    plateNumberController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    vehicleLicenseExpiryController.dispose();
    contractExpiryController.dispose();
  }

  void resolveInitialTypeLabel(
    BuildContext context,
    List<DriverVehicleTypeEntity> vehicleTypes,
  ) {
    if (didResolveInitialTypeLabel || selectedVehicleTypeCode.isEmpty) return;
    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    for (final type in vehicleTypes) {
      if (type.code.trim() == selectedVehicleTypeCode) {
        vehicleTypeController.text = isArabic ? type.nameAr : type.nameEn;
        didResolveInitialTypeLabel = true;
        return;
      }
    }
  }

  Future<void> pickVehicleType({
    required BuildContext context,
    required List<DriverVehicleTypeEntity> vehicleTypes,
    void Function(String search, String? vehicleType)?
    onVehicleModelQueryChanged,
  }) async {
    _modelSearchDebounce?.cancel();
    isModelQueryPending.value = false;

    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    String typeLabel(DriverVehicleTypeEntity type) =>
        isArabic ? type.nameAr : type.nameEn;

    final selectableTypes = vehicleTypes
        .where((type) => type.code.trim().isNotEmpty)
        .toList();
    final typeMap = <String, DriverVehicleTypeEntity>{};
    for (final t in selectableTypes) {
      typeMap[typeLabel(t)] = t;
    }
    final labels = typeMap.keys.toList();

    DriverVehicleTypeEntity? selectedType;
    for (final type in selectableTypes) {
      if (type.code.trim() == selectedVehicleTypeCode) {
        selectedType = type;
        break;
      }
    }

    final selected = await AppWoltPickerSheet.show(
      context: context,
      title: context.localization.registrationVehicleType,
      items: labels,
      selectedItem: selectedType == null ? null : typeLabel(selectedType),
      itemLeadingIcon: Icons.directions_car_rounded,
      searchHint: context.localization.registrationVehicleTypeHint,
    );

    if (selected != null && context.mounted) {
      final chosen = typeMap[selected];
      if (chosen == null) return;
      _modelSearchDebounce?.cancel();
      selectedVehicleTypeCode = chosen.code.trim();
      vehicleTypeController.text = selected;
      modelController.clear();
      selectedVehicleModelValue = null;
      isModelQueryPending.value = false;

      onVehicleModelQueryChanged?.call('', selectedVehicleTypeCode);
    }
  }

  void handleModelChanged({
    required String value,
    void Function(String search, String? vehicleType)?
    onVehicleModelQueryChanged,
    void Function(String search, String? vehicleType)? onSearchVehicleModels,
  }) {
    selectedVehicleModelValue = null;
    _modelSearchDebounce?.cancel();
    isModelQueryPending.value = true;
    onVehicleModelQueryChanged?.call(
      value,
      selectedVehicleTypeCode.isEmpty ? null : selectedVehicleTypeCode,
    );
    _modelSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      isModelQueryPending.value = false;
      onSearchVehicleModels?.call(
        value,
        selectedVehicleTypeCode.isEmpty ? null : selectedVehicleTypeCode,
      );
    });
  }

  void selectModel(DriverVehicleModelEntity model, String label) {
    _modelSearchDebounce?.cancel();
    selectedVehicleModelValue = model.value.trim();
    modelController.text = label;
    modelController.selection = TextSelection.collapsed(
      offset: modelController.text.length,
    );
    modelFocusNode.unfocus();
  }

  Future<void> pickManufactureYear(BuildContext context) async {
    final now = DateTime.now();
    final currentYear = int.tryParse(manufactureYearController.text);
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

    if (selected != null && context.mounted) {
      manufactureYearController.text = selected.year.toString();
    }
  }

  Future<void> pickExpiryDate({
    required BuildContext context,
    required TextEditingController controller,
    required String title,
  }) async {
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
    if (selected != null && context.mounted) {
      controller.text = DateTime(
        selected.year,
        selected.month,
        selected.day,
      ).toIso8601String();
    }
  }

  void handleColorSelected(String hex, ValueChanged<Color> onColorSelected) {
    final canonical = canonicalVehicleColorHex(hex);
    if (canonical == null) return;
    selectedColorHex.value = canonical;
    onColorSelected(
      Color(0xFF000000 | int.parse(canonical.substring(1), radix: 16)),
    );
  }

  void clearContractExpiry() {
    contractExpiryController.clear();
  }

  RegisterVehicleData toVehicleData({String country = ''}) {
    String isoDateValue(TextEditingController c) =>
        DateTime.parse(c.text.trim()).toIso8601String();

    return RegisterVehicleData(
      type: selectedVehicleTypeCode,
      model: selectedVehicleModelValue ?? modelController.text.trim(),
      manufactureYear: manufactureYearController.text.trim(),
      plateNumber: plateNumberController.text.trim(),
      country: country,
      color: selectedColorHex.value,
      isOwned: ownsVehicle.value,
      licenseNumber: licenseNumberController.text.trim(),
      licenseExpiry: isoDateValue(licenseExpiryController),
      vehicleLicenseExpiry: isoDateValue(vehicleLicenseExpiryController),
      contractExpiry: contractExpiryController.text.trim().isEmpty
          ? null
          : isoDateValue(contractExpiryController),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';
import '../../../../core/widget/app_wolt_modal_sheet.dart';
import '../../../auth/presentation/widgets/registration_choice_group.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
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
    this.onBackPressed,
  });

  final Color selectedVehicleColor;
  final bool ownsVehicle;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<bool> onOwnsVehicleChanged;
  final VoidCallback onContinue;
  final VoidCallback? onBackPressed;

  @override
  State<RegisterVehicleDataScreen> createState() =>
      _RegisterVehicleDataScreenState();
}

class _RegisterVehicleDataScreenState
    extends State<RegisterVehicleDataScreen> {
  late final TextEditingController _vehicleTypeController;
  late final TextEditingController _manufactureYearController;

  @override
  void initState() {
    super.initState();
    _vehicleTypeController = TextEditingController();
    _manufactureYearController = TextEditingController();
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _manufactureYearController.dispose();
    super.dispose();
  }

  Future<void> _pickVehicleType() async {
    final selected = await AppWoltPickerSheet.show(
      context: context,
      title: context.localization.registrationVehicleType,
      items: RegistrationFakeData.vehicleTypes,
      selectedItem: _vehicleTypeController.text.isNotEmpty
          ? _vehicleTypeController.text
          : null,
      itemLeadingIcon: Icons.directions_car_rounded,
      searchHint: 'ابحث عن نوع المركبة...',
    );

    if (selected != null && mounted) {
      setState(() {
        _vehicleTypeController.text = selected;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegistrationScaffold(
      title: locale.registrationVehicleData,
      currentStep: 2,
      onBackPressed: widget.onBackPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegistrationInputField(
            label: locale.registrationVehicleType,
            hint: locale.registrationVehicleTypeHint,
            isPicker: true,
            controller: _vehicleTypeController,
            onTap: _pickVehicleType,
            prefixIcon: Icons.directions_car_rounded,
            showPickerArrow: true,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationVehicleModel,
            hint: locale.registrationVehicleModelHint,
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
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegisterPlateNumberField(locale: locale),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegisterVehicleColorPicker(
            selectedColor: widget.selectedVehicleColor,
            onColorSelected: widget.onColorSelected,
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
          const SizedBox(height: Spacing.lg),
          AppButton(
            text: locale.registrationContinue,
            onPressed: widget.onContinue,
            height: Spacing.registrationButtonHeight,
            borderRadius: Spacing.registrationRadius,
          ),
          const SizedBox(height: Spacing.screenV),
        ],
      ),
    );
  }
}

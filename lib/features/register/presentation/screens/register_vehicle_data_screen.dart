import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';
import '../../../auth/presentation/widgets/registration_choice_group.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../widgets/register_plate_number_field.dart';
import '../widgets/register_vehicle_color_picker.dart';

class RegisterVehicleDataScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegistrationScaffold(
      title: locale.registrationVehicleData,
      currentStep: 2,
      onBackPressed: onBackPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegistrationInputField(
            label: locale.registrationVehicleType,
            hint: locale.registrationVehicleTypeHint,
            isPicker: true,
            prefixIcon: Icons.directions_car_rounded,
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
            suffixIcon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegisterPlateNumberField(locale: locale),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegisterVehicleColorPicker(
            selectedColor: selectedVehicleColor,
            onColorSelected: onColorSelected,
          ),
          const SizedBox(height: Spacing.xxl),
          RegistrationChoiceGroup(
            label: locale.registrationOwnVehicle,
            firstText: locale.registrationYes,
            secondText: locale.registrationNo,
            firstSelected: ownsVehicle,
            onFirstTap: () => onOwnsVehicleChanged(true),
            onSecondTap: () => onOwnsVehicleChanged(false),
          ),
          const SizedBox(height: Spacing.lg),
          AppButton(
            text: locale.registrationContinue,
            onPressed: onContinue,
            height: Spacing.registrationButtonHeight,
            borderRadius: Spacing.registrationRadius,
          ),
          const SizedBox(height: Spacing.screenV),
        ],
      ),
    );
  }
}

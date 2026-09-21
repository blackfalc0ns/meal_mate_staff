import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../auth/presentation/widgets/registration_choice_group.dart';
import '../../domain/entities/driver_vehicle_color_entity.dart';
import '../controllers/register_vehicle_data_form_controller.dart';
import 'register_section_card.dart';
import 'register_vehicle_color_picker.dart';

class RegisterVehicleOwnershipSection extends StatelessWidget {
  const RegisterVehicleOwnershipSection({
    super.key,
    required this.formController,
    required this.vehicleColors,
    required this.onColorSelected,
    required this.onOwnsVehicleChanged,
  });

  final RegisterVehicleDataFormController formController;
  final List<DriverVehicleColorEntity> vehicleColors;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<bool> onOwnsVehicleChanged;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegisterSectionCard(
      title: locale.registrationVehicleColor,
      icon: Icons.palette_outlined,
      children: [
        ValueListenableBuilder<String>(
          valueListenable: formController.selectedColorHex,
          builder: (context, colorHex, _) {
            return FormField<String>(
              initialValue: colorHex,
              validator: (_) => context.validateRequired(colorHex),
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RegisterVehicleColorPicker(
                    colors: vehicleColors,
                    selectedHex: colorHex,
                    onColorSelected: (hex) {
                      formController.handleColorSelected(hex, onColorSelected);
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
            );
          },
        ),
        const SizedBox(height: Spacing.xl),
        ValueListenableBuilder<bool>(
          valueListenable: formController.ownsVehicle,
          builder: (context, isOwned, _) {
            return RegistrationChoiceGroup(
              label: locale.registrationOwnVehicle,
              firstText: locale.registrationYes,
              secondText: locale.registrationNo,
              firstSelected: isOwned,
              onFirstTap: () {
                formController.ownsVehicle.value = true;
                onOwnsVehicleChanged(true);
              },
              onSecondTap: () {
                formController.ownsVehicle.value = false;
                onOwnsVehicleChanged(false);
              },
            );
          },
        ),
      ],
    );
  }
}

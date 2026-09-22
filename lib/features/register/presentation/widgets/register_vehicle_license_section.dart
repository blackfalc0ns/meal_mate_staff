import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../controllers/register_vehicle_data_form_controller.dart';
import 'register_plate_number_field.dart';
import 'register_section_card.dart';

class RegisterVehicleLicenseSection extends StatelessWidget {
  const RegisterVehicleLicenseSection({
    super.key,
    required this.formController,
  });

  final RegisterVehicleDataFormController formController;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegisterSectionCard(
      title: locale.registrationLicensesAndPlate,
      icon: Icons.badge_outlined,
      children: [
        RegisterPlateNumberField(
          locale: locale,
          controller: formController.plateNumberController,
          validator: (v) => context.validateRequired(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.driverVehicleLicenseNumberLabel,
          hint: locale.driverVehicleLicenseNumberLabel,
          controller: formController.licenseNumberController,
          validator: (v) => context.validateRequired(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationLicenseExpiry,
          hint: locale.registrationDateHint,
          isPicker: true,
          prefixIcon: Icons.calendar_month_rounded,
          controller: formController.licenseExpiryController,
          onTap: () => formController.pickExpiryDate(
            context: context,
            controller: formController.licenseExpiryController,
            title: locale.registrationLicenseExpiry,
          ),
          validator: context.validateFutureDate,
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationVehicleLicenseExpiry,
          hint: locale.registrationDateHint,
          isPicker: true,
          prefixIcon: Icons.calendar_month_rounded,
          controller: formController.vehicleLicenseExpiryController,
          onTap: () => formController.pickExpiryDate(
            context: context,
            controller: formController.vehicleLicenseExpiryController,
            title: locale.registrationVehicleLicenseExpiry,
          ),
          validator: context.validateFutureDate,
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        ListenableBuilder(
          listenable: formController.contractExpiryController,
          builder: (context, _) {
            final hasText = formController.contractExpiryController.text
                .trim()
                .isNotEmpty;
            return RegistrationInputField(
              label: locale.registrationContractExpiry,
              hint: locale.registrationDateHint,
              isPicker: true,
              prefixIcon: Icons.calendar_month_rounded,
              controller: formController.contractExpiryController,
              suffixIcon: hasText ? Icons.clear_rounded : null,
              suffixTooltip: locale.registrationClearContractExpiry,
              onSuffixTap: formController.clearContractExpiry,
              onTap: () => formController.pickExpiryDate(
                context: context,
                controller: formController.contractExpiryController,
                title: locale.registrationContractExpiry,
              ),
              validator: context.validateOptionalFutureDate,
            );
          },
        ),
      ],
    );
  }
}

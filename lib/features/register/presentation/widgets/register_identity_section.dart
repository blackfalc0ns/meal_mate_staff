import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../controllers/register_personal_data_form_controller.dart';
import 'register_section_card.dart';

class RegisterIdentitySection extends StatelessWidget {
  const RegisterIdentitySection({super.key, required this.formController});

  final RegisterPersonalDataFormController formController;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegisterSectionCard(
      title: locale.registrationIdentityAndContact,
      icon: Icons.badge_outlined,
      children: [
        RegistrationInputField(
          label: locale.registrationCivilId,
          hint: locale.registrationCivilIdHint,
          controller: formController.civilId,
          keyboardType: TextInputType.number,
          validator: (v) => context.validateNationalId(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationIdExpiry,
          hint: locale.registrationIdExpiryHint,
          isPicker: true,
          prefixIcon: Icons.calendar_month_rounded,
          showPickerArrow: false,
          controller: formController.nationalIdExpiry,
          onTap: () => formController.pickNationalIdExpiry(context),
          validator: (v) => context.validateFutureDate(v),
        ),
      ],
    );
  }
}

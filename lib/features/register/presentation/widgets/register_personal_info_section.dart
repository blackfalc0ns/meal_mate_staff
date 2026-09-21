import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../domain/entities/driver_nationality_entity.dart';
import '../controllers/register_personal_data_form_controller.dart';
import 'register_section_card.dart';

class RegisterPersonalInfoSection extends StatelessWidget {
  const RegisterPersonalInfoSection({
    super.key,
    required this.formController,
    required this.nationalities,
  });

  final RegisterPersonalDataFormController formController;
  final List<DriverNationalityEntity> nationalities;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegisterSectionCard(
      title: locale.registrationPersonalData,
      icon: Icons.person_outline_rounded,
      children: [
        RegistrationInputField(
          label: locale.registrationFullNameAr,
          hint: locale.registrationFullNameArHint,
          controller: formController.fullNameAr,
          validator: (v) => context.validateName(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationFullNameEn,
          hint: locale.registrationFullNameEnHint,
          controller: formController.fullNameEn,
          validator: (v) => context.validateName(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationPhone,
          hint: locale.registrationPhoneHint,
          controller: formController.phone,
          keyboardType: TextInputType.phone,
          validator: (v) => context.validatePhoneNumber(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationEmail,
          hint: locale.registrationEmailHint,
          controller: formController.email,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => context.validateOptionalEmail(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationBirthDate,
          hint: locale.registrationBirthDateHint,
          isPicker: true,
          prefixIcon: Icons.calendar_month_rounded,
          showPickerArrow: false,
          controller: formController.birthDate,
          onTap: () => formController.pickBirthDate(context),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationNationality,
          hint: locale.registrationNationalityHint,
          isPicker: true,
          controller: formController.nationality,
          onTap: () => formController.pickNationality(context, nationalities),
          validator: (v) => context.validateRequired(v),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../domain/entities/driver_nationality_entity.dart';
import '../controllers/register_personal_data_form_controller.dart';
import 'register_section_card.dart';

class RegisterPersonalInfoSection extends StatefulWidget {
  const RegisterPersonalInfoSection({
    super.key,
    required this.formController,
    required this.nationalities,
  });

  final RegisterPersonalDataFormController formController;
  final List<DriverNationalityEntity> nationalities;

  @override
  State<RegisterPersonalInfoSection> createState() =>
      _RegisterPersonalInfoSectionState();
}

class _RegisterPersonalInfoSectionState
    extends State<RegisterPersonalInfoSection> {
  bool _obscurePassword = true;

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
          controller: widget.formController.fullNameAr,
          validator: (v) => context.validateName(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationFullNameEn,
          hint: locale.registrationFullNameEnHint,
          controller: widget.formController.fullNameEn,
          validator: (v) => context.validateName(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationPhone,
          hint: locale.registrationPhoneHint,
          controller: widget.formController.phone,
          keyboardType: TextInputType.phone,
          validator: (v) => context.validatePhoneNumber(v),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          fieldKey: const Key('driver_registration_password_field'),
          label: locale.passwordLabel,
          hint: locale.passwordHint,
          controller: widget.formController.password,
          obscureText: _obscurePassword,
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          suffixTooltip: _obscurePassword
              ? locale.showPassword
              : locale.hidePassword,
          onSuffixTap: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          validator: context.validatePassword,
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationEmail,
          hint: locale.registrationEmailHint,
          controller: widget.formController.email,
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
          controller: widget.formController.birthDate,
          onTap: () => widget.formController.pickBirthDate(context),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationNationality,
          hint: locale.registrationNationalityHint,
          isPicker: true,
          controller: widget.formController.nationality,
          onTap: () => widget.formController.pickNationality(
            context,
            widget.nationalities,
          ),
          validator: (v) => context.validateRequired(v),
        ),
      ],
    );
  }
}

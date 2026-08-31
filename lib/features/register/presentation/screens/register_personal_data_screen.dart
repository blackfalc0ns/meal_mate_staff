import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';

class RegisterPersonalDataScreen extends StatelessWidget {
  const RegisterPersonalDataScreen({
    super.key,
    required this.onContinue,
    this.onBackPressed,
  });

  final VoidCallback onContinue;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegistrationScaffold(
      title: locale.registrationPersonalData,
      currentStep: 1,
      onBackPressed: onBackPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegistrationInputField(
            label: locale.registrationFirstName,
            hint: locale.registrationFirstNameHint,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationLastName,
            hint: locale.registrationLastNameHint,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationPhone,
            hint: locale.registrationPhoneHint,
            prefix: '+962',
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationEmail,
            hint: locale.registrationEmailHint,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationBirthDate,
            hint: locale.registrationBirthDateHint,
            isPicker: true,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationNationality,
            hint: locale.registrationNationalityHint,
            isPicker: true,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationCivilId,
            hint: locale.registrationCivilIdHint,
          ),
          const SizedBox(height: Spacing.xl),
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

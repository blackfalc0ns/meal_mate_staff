import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';
import '../../../../core/widget/app_wolt_modal_sheet.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';

class RegisterPersonalDataScreen extends StatefulWidget {
  const RegisterPersonalDataScreen({
    super.key,
    required this.onContinue,
    this.onBackPressed,
  });

  final VoidCallback onContinue;
  final VoidCallback? onBackPressed;

  @override
  State<RegisterPersonalDataScreen> createState() =>
      _RegisterPersonalDataScreenState();
}

class _RegisterPersonalDataScreenState
    extends State<RegisterPersonalDataScreen> {
  late final TextEditingController _birthDateController;
  late final TextEditingController _nationalityController;

  @override
  void initState() {
    super.initState();
    _birthDateController = TextEditingController();
    _nationalityController = TextEditingController();
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final selected = await AppWoltPickerSheet.showDatePicker(
      context: context,
      title: context.localization.registrationBirthDate,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selected != null && mounted) {
      final formatted =
          '${selected.year}/${selected.month.toString().padLeft(2, '0')}/${selected.day.toString().padLeft(2, '0')}';
      setState(() {
        _birthDateController.text = formatted;
      });
    }
  }

  Future<void> _pickNationality() async {
    final selected = await AppWoltPickerSheet.show(
      context: context,
      title: context.localization.registrationNationality,
      items: RegistrationFakeData.nationalities,
      selectedItem: _nationalityController.text.isNotEmpty
          ? _nationalityController.text
          : null,
      itemLeadingIcon: Icons.flag_rounded,
      searchHint: 'ابحث عن الجنسية...',
    );

    if (selected != null && mounted) {
      setState(() {
        _nationalityController.text = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return RegistrationScaffold(
      title: locale.registrationPersonalData,
      currentStep: 1,
      onBackPressed: widget.onBackPressed,
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
            controller: _birthDateController,
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationNationality,
            hint: locale.registrationNationalityHint,
            isPicker: true,
            controller: _nationalityController,
            onTap: _pickNationality,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationCivilId,
            hint: locale.registrationCivilIdHint,
          ),
          const SizedBox(height: Spacing.xl),
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

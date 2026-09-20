import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/widget/app_button.dart';
import '../../../../core/widget/app_wolt_modal_sheet.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/register_personal_data.dart';

class RegisterPersonalDataScreen extends StatefulWidget {
  const RegisterPersonalDataScreen({
    super.key,
    required this.onContinue,
    this.onBackPressed,
    this.initialData,
    this.restaurants = const [],
    this.onPersonalDataChanged,
  });

  final VoidCallback onContinue;
  final VoidCallback? onBackPressed;
  final RegisterPersonalData? initialData;
  final List<DriverRestaurantEntity> restaurants;
  final ValueChanged<RegisterPersonalData>? onPersonalDataChanged;

  @override
  State<RegisterPersonalDataScreen> createState() =>
      _RegisterPersonalDataScreenState();
}

class _RegisterPersonalDataScreenState
    extends State<RegisterPersonalDataScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _civilIdController;
  String _selectedRestaurantId = '';
  String _selectedRestaurantName = '';

  @override
  void initState() {
    super.initState();
    final init = widget.initialData;
    _firstNameController = TextEditingController(text: init?.firstName ?? '');
    _lastNameController = TextEditingController(text: init?.lastName ?? '');
    _phoneController = TextEditingController(text: init?.phone ?? '');
    _emailController = TextEditingController(text: init?.email ?? '');
    _birthDateController = TextEditingController(text: init?.birthDate ?? '');
    _nationalityController = TextEditingController(
      text: init?.nationality ?? '',
    );
    _civilIdController = TextEditingController(text: init?.civilId ?? '');

    _selectedRestaurantId = init?.restaurantId ?? '';
    _selectedRestaurantName = init?.restaurantName ?? '';
    if (_selectedRestaurantId.isEmpty && widget.restaurants.isNotEmpty) {
      _selectedRestaurantId = widget.restaurants.first.id;
      _selectedRestaurantName = widget.restaurants.first.tradeName;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _nationalityController.dispose();
    _civilIdController.dispose();
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

  void _handleContinue() {
    final data = RegisterPersonalData(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      nationality: _nationalityController.text.trim(),
      civilId: _civilIdController.text.trim(),
      restaurantId: _selectedRestaurantId,
      restaurantName: _selectedRestaurantName,
      fullNameAr:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
              .trim(),
      fullNameEn:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
              .trim(),
    );
    widget.onPersonalDataChanged?.call(data);
    widget.onContinue();
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
            controller: _firstNameController,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationLastName,
            hint: locale.registrationLastNameHint,
            controller: _lastNameController,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationPhone,
            hint: locale.registrationPhoneHint,
            prefix: '+962',
            controller: _phoneController,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationEmail,
            hint: locale.registrationEmailHint,
            controller: _emailController,
          ),
          const SizedBox(height: Spacing.registrationFieldGap),
          RegistrationInputField(
            label: locale.registrationBirthDate,
            hint: locale.registrationBirthDateHint,
            isPicker: true,
            prefixIcon: Icons.calendar_month_rounded,
            showPickerArrow: false,
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
            controller: _civilIdController,
          ),
          const SizedBox(height: Spacing.xl),
          AppButton(
            text: locale.registrationContinue,
            onPressed: _handleContinue,
            height: Spacing.registrationButtonHeight,
            borderRadius: Spacing.registrationRadius,
          ),
          const SizedBox(height: Spacing.screenV),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/network/network_constants.dart';
import '../../../../core/widget/app_button.dart';
import '../../../../core/widget/app_wolt_modal_sheet.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/entities/driver_nationality_entity.dart';
import '../../domain/register_personal_data.dart';

class RegisterPersonalDataScreen extends StatefulWidget {
  const RegisterPersonalDataScreen({
    super.key,
    required this.onContinue,
    this.onBackPressed,
    this.initialData,
    this.restaurants = const [],
    this.nationalities = const [],
    this.onPersonalDataChanged,
    this.failure,
  });

  final VoidCallback onContinue;
  final VoidCallback? onBackPressed;
  final RegisterPersonalData? initialData;
  final List<DriverRestaurantEntity> restaurants;
  final List<DriverNationalityEntity> nationalities;
  final ValueChanged<RegisterPersonalData>? onPersonalDataChanged;
  final Failure? failure;

  @override
  State<RegisterPersonalDataScreen> createState() =>
      _RegisterPersonalDataScreenState();
}

class _RegisterPersonalDataScreenState
    extends State<RegisterPersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameArController;
  late final TextEditingController _fullNameEnController;
  late final TextEditingController _restaurantController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _civilIdController;
  late final TextEditingController _nationalIdExpiryController;
  String _selectedRestaurantId = '';
  String _selectedRestaurantName = '';

  @override
  void initState() {
    super.initState();
    final init = widget.initialData;
    _fullNameArController = TextEditingController(
      text: init?.resolvedFullNameAr ?? '',
    );
    _fullNameEnController = TextEditingController(
      text: init?.resolvedFullNameEn ?? '',
    );
    _restaurantController = TextEditingController(
      text: init?.restaurantName ?? '',
    );
    _phoneController = TextEditingController(text: init?.phone ?? '');
    _emailController = TextEditingController(text: init?.email ?? '');
    _birthDateController = TextEditingController(text: init?.birthDate ?? '');
    _nationalityController = TextEditingController(
      text: init?.nationality ?? '',
    );
    _civilIdController = TextEditingController(text: init?.civilId ?? '');
    _nationalIdExpiryController = TextEditingController(
      text: init?.nationalIdExpiry ?? '',
    );

    _selectedRestaurantId = init?.restaurantId ?? '';
    _selectedRestaurantName = init?.restaurantName ?? '';
  }

  @override
  void dispose() {
    _fullNameArController.dispose();
    _fullNameEnController.dispose();
    _restaurantController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _nationalityController.dispose();
    _civilIdController.dispose();
    _nationalIdExpiryController.dispose();
    super.dispose();
  }

  Future<void> _pickRestaurant() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final labels = widget.restaurants
        .map((item) => isArabic ? item.tradeNameAr : item.tradeNameEn)
        .toList();
    final selected = await AppWoltPickerSheet.show(
      context: context,
      title: context.localization.registrationRestaurant,
      items: labels,
      selectedItem: _restaurantController.text.isEmpty
          ? null
          : _restaurantController.text,
      searchHint: context.localization.registrationRestaurantHint,
      itemLeadingBuilder: (label) {
        final item = widget.restaurants[labels.indexOf(label)];
        final rawLogoUrl = item.logoUrl;
        final logoUrl = rawLogoUrl == null || rawLogoUrl.isEmpty
            ? null
            : Uri.parse(
                NetworkConstants.baseUrl,
              ).resolve(rawLogoUrl).toString();
        return CircleAvatar(
          radius: 16,
          backgroundImage: logoUrl == null ? null : NetworkImage(logoUrl),
          child: logoUrl != null
              ? null
              : const Icon(Icons.restaurant_rounded, size: 18),
        );
      },
    );
    if (selected == null || !mounted) return;
    final item = widget.restaurants[labels.indexOf(selected)];
    setState(() {
      _selectedRestaurantId = item.id;
      _selectedRestaurantName = selected;
      _restaurantController.text = selected;
    });
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
      items: widget.nationalities
          .map(
            (item) =>
                '${item.flagEmoji} ${Localizations.localeOf(context).languageCode == 'ar' ? item.nameAr : item.nameEn}',
          )
          .toList(),
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

  Future<void> _pickNationalIdExpiry() async {
    final now = DateTime.now();
    final selected = await AppWoltPickerSheet.showDatePicker(
      context: context,
      title: context.localization.registrationIdExpiry,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 30),
    );
    if (selected != null && mounted) {
      _nationalIdExpiryController.text =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  void _handleContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final englishParts = _fullNameEnController.text.trim().split(
      RegExp(r'\s+'),
    );
    final data = RegisterPersonalData(
      firstName: englishParts.first,
      lastName: englishParts.length > 1 ? englishParts.skip(1).join(' ') : '',
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      nationality: _nationalityController.text.trim(),
      civilId: _civilIdController.text.trim(),
      restaurantId: _selectedRestaurantId,
      restaurantName: _selectedRestaurantName,
      fullNameAr: _fullNameArController.text.trim(),
      fullNameEn: _fullNameEnController.text.trim(),
      nationalIdExpiry: _nationalIdExpiryController.text.trim(),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationInputField(
              label: locale.registrationRestaurant,
              hint: locale.registrationRestaurantHint,
              controller: _restaurantController,
              isPicker: true,
              onTap: _pickRestaurant,
              validator: (v) => context.validateRequired(_selectedRestaurantId),
            ),
            Text(locale.registrationRestaurantHelp),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationFullNameAr,
              hint: locale.registrationFullNameArHint,
              controller: _fullNameArController,
              validator: (v) => context.validateName(v),
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationFullNameEn,
              hint: locale.registrationFullNameEnHint,
              controller: _fullNameEnController,
              validator: (v) => context.validateName(v),
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationPhone,
              hint: locale.registrationPhoneHint,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) => context.validatePhoneNumber(v),
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationEmail,
              hint: locale.registrationEmailHint,
              controller: _emailController,
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
              validator: (v) => context.validateRequired(v),
            ),
            const SizedBox(height: Spacing.registrationFieldGap),
            RegistrationInputField(
              label: locale.registrationCivilId,
              hint: locale.registrationCivilIdHint,
              controller: _civilIdController,
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
              controller: _nationalIdExpiryController,
              onTap: _pickNationalIdExpiry,
              validator: (v) => context.validateFutureDate(v),
            ),
            if (widget.failure != null) ...[
              const SizedBox(height: Spacing.md),
              InlineApiErrorWidget(failure: widget.failure!),
            ],
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
      ),
    );
  }
}

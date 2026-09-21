import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/widget/app_button.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../../domain/entities/driver_nationality_entity.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/register_personal_data.dart';
import '../controllers/register_personal_data_form_controller.dart';
import '../widgets/register_identity_section.dart';
import '../widgets/register_personal_info_section.dart';
import '../widgets/register_workplace_section.dart';

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
  late final RegisterPersonalDataFormController _formController;

  @override
  void initState() {
    super.initState();
    _formController = RegisterPersonalDataFormController(widget.initialData);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onPersonalDataChanged?.call(_formController.toPersonalData());
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
            RegisterWorkplaceSection(
              formController: _formController,
              restaurants: widget.restaurants,
            ),
            RegisterPersonalInfoSection(
              formController: _formController,
              nationalities: widget.nationalities,
            ),
            RegisterIdentitySection(
              formController: _formController,
            ),
            if (widget.failure != null) ...[
              const SizedBox(height: Spacing.xs),
              InlineApiErrorWidget(failure: widget.failure!),
              const SizedBox(height: Spacing.sm),
            ],
            const SizedBox(height: Spacing.sm),
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

import 'package:flutter/material.dart';

import '../../../../config/theme/font_manager.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/styles_manager.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../controllers/register_personal_data_form_controller.dart';
import 'register_section_card.dart';

class RegisterWorkplaceSection extends StatelessWidget {
  const RegisterWorkplaceSection({
    super.key,
    required this.formController,
    required this.restaurants,
  });

  final RegisterPersonalDataFormController formController;
  final List<DriverRestaurantEntity> restaurants;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;
    final color = context.colorScheme;

    return RegisterSectionCard(
      title: locale.registrationWorkplace,
      icon: Icons.storefront_rounded,
      children: [
        RegistrationInputField(
          label: locale.registrationRestaurant,
          hint: locale.registrationRestaurantHint,
          controller: formController.restaurant,
          isPicker: true,
          onTap: () => formController.pickRestaurant(context, restaurants),
          validator: (v) =>
              context.validateRequired(formController.selectedRestaurantId),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            top: Spacing.xs,
            start: Spacing.xs,
          ),
          child: Text(
            locale.registrationRestaurantHelp,
            style: getRegularStyle(
              color: color.onSurfaceVariant,
              fontSize: FontSize.size11,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/validators.dart';
import '../../../auth/presentation/widgets/registration_input_field.dart';
import '../../domain/entities/driver_vehicle_model_entity.dart';
import '../../domain/entities/driver_vehicle_type_entity.dart';
import '../controllers/register_vehicle_data_form_controller.dart';
import 'register_section_card.dart';

class RegisterVehicleSpecsSection extends StatelessWidget {
  const RegisterVehicleSpecsSection({
    super.key,
    required this.formController,
    required this.vehicleTypes,
    required this.vehicleModels,
    required this.isSearchingVehicleModels,
    this.onVehicleModelQueryChanged,
    this.onSearchVehicleModels,
  });

  final RegisterVehicleDataFormController formController;
  final List<DriverVehicleTypeEntity> vehicleTypes;
  final List<DriverVehicleModelEntity> vehicleModels;
  final bool isSearchingVehicleModels;
  final void Function(String search, String? vehicleType)?
  onVehicleModelQueryChanged;
  final void Function(String search, String? vehicleType)?
  onSearchVehicleModels;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;
    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    String modelLabel(DriverVehicleModelEntity model) =>
        isArabic ? model.fullNameAr : model.fullNameEn;

    return RegisterSectionCard(
      title: locale.registrationVehicleSpecifications,
      icon: Icons.directions_car_rounded,
      children: [
        RegistrationInputField(
          label: locale.registrationVehicleType,
          hint: locale.registrationVehicleTypeHint,
          isPicker: true,
          controller: formController.vehicleTypeController,
          onTap: () => formController.pickVehicleType(
            context: context,
            vehicleTypes: vehicleTypes,
            onVehicleModelQueryChanged: onVehicleModelQueryChanged,
          ),
          prefixIcon: Icons.directions_car_rounded,
          showPickerArrow: true,
          validator: (_) =>
              context.validateRequired(formController.selectedVehicleTypeCode),
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationVehicleModel,
          hint: locale.registrationVehicleModelHint,
          controller: formController.modelController,
          focusNode: formController.modelFocusNode,
          onChanged: (v) => formController.handleModelChanged(
            value: v,
            onVehicleModelQueryChanged: onVehicleModelQueryChanged,
            onSearchVehicleModels: onSearchVehicleModels,
          ),
          validator: (v) => context.validateRequired(v),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: formController.isModelQueryPending,
          builder: (context, isPending, _) {
            if (isSearchingVehicleModels || isPending) {
              return const Padding(
                padding: EdgeInsets.only(top: Spacing.xs),
                child: LinearProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        ListenableBuilder(
          listenable: Listenable.merge([
            formController.modelFocusNode,
            formController.modelController,
            formController.isModelQueryPending,
          ]),
          builder: (context, _) {
            if (formController.modelFocusNode.hasFocus &&
                !formController.isModelQueryPending.value &&
                formController.modelController.text.trim().isNotEmpty &&
                vehicleModels.isNotEmpty) {
              return Material(
                color: context.colorScheme.surface,
                child: Column(
                  children: vehicleModels
                      .where((model) => model.value.trim().isNotEmpty)
                      .map(
                        (model) => ListTile(
                          dense: true,
                          title: Text(modelLabel(model)),
                          onTap: () => formController.selectModel(
                            model,
                            modelLabel(model),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: Spacing.registrationFieldGap),
        RegistrationInputField(
          label: locale.registrationManufactureYear,
          hint: locale.registrationManufactureYearHint,
          isPicker: true,
          prefixIcon: Icons.calendar_month_rounded,
          showPickerArrow: false,
          controller: formController.manufactureYearController,
          onTap: () => formController.pickManufactureYear(context),
          validator: context.validateManufactureYear,
        ),
      ],
    );
  }
}

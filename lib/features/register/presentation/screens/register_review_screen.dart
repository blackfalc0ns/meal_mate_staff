import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/l10n/translations/app_localizations.dart';
import '../../../auth/presentation/widgets/registration_note_card.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../../data/register_fake_data.dart';
import '../../domain/register_document.dart';
import '../../domain/register_personal_data.dart';
import '../../domain/register_vehicle_data.dart';
import '../widgets/register_action_buttons.dart';
import '../widgets/register_review_card.dart';
import '../widgets/register_review_field.dart';
import '../widgets/register_uploaded_documents_card.dart';

class RegisterReviewScreen extends StatelessWidget {
  const RegisterReviewScreen({
    super.key,
    required this.selectedImagePaths,
    required this.onDocumentTap,
    required this.onSubmit,
    required this.onBackToEdit,
  });

  final Map<String, String> selectedImagePaths;
  final ValueChanged<RegisterDocument> onDocumentTap;
  final VoidCallback onSubmit;
  final VoidCallback onBackToEdit;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;
    const review = RegisterFakeData.review;

    return RegistrationScaffold(
      title: locale.registrationReviewOrder,
      subtitle: locale.registrationReviewSubtitle,
      currentStep: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RegisterReviewCard(
            title: locale.registrationPersonalData,
            onEdit: onBackToEdit,
            children: _personalFields(locale, review.personal),
          ),
          const SizedBox(height: Spacing.md),
          RegisterReviewCard(
            title: locale.registrationVehicleData,
            onEdit: onBackToEdit,
            children: _vehicleFields(locale, review.vehicle),
          ),
          const SizedBox(height: Spacing.md),
          RegisterUploadedDocumentsCard(
            documents: review.documents,
            documentTitles: _documentTitles(locale),
            selectedImagePaths: selectedImagePaths,
            onDocumentTap: onDocumentTap,
          ),
          const SizedBox(height: Spacing.md),
          RegistrationNoteCard(
            text: locale.registrationReviewNote,
            icon: Icons.info_rounded,
          ),
          const SizedBox(height: Spacing.md),
          RegisterActionButtons(onSubmit: onSubmit, onBackToEdit: onBackToEdit),
          const SizedBox(height: Spacing.screenV),
        ],
      ),
    );
  }

  List<Widget> _personalFields(
    AppLocalizations locale,
    RegisterPersonalData personal,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationFirstName,
              value: personal.firstName,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationLastName,
              value: personal.lastName,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationPhone,
              value: personal.phone,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationEmail,
              value: personal.email,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationBirthDate,
              value: personal.birthDate,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationNationality,
              value: personal.nationality,
            ),
          ),
        ],
      ),
      RegisterReviewField(
        label: locale.registrationCivilId,
        value: personal.civilId,
      ),
    ];
  }

  List<Widget> _vehicleFields(
    AppLocalizations locale,
    RegisterVehicleData vehicle,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationVehicleType,
              value: locale.registrationCar,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationVehicleModel,
              value: vehicle.model,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationManufactureYear,
              value: vehicle.manufactureYear,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationPlateNumber,
              value: vehicle.plateNumber,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationCountry,
              value: locale.registrationKuwait,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: RegisterReviewField(
              label: locale.registrationVehicleColor,
              value: locale.registrationPurple,
            ),
          ),
        ],
      ),
      RegisterReviewField(
        label: locale.registrationOwnVehicle,
        value: vehicle.isOwned ? locale.registrationYes : locale.registrationNo,
      ),
    ];
  }

  Map<String, String> _documentTitles(AppLocalizations locale) {
    return {
      'civil-card': locale.registrationCivilCard,
      'driving-license': locale.registrationDrivingLicense,
      'car-registration': locale.registrationCarRegistration,
      'vehicle-photo': locale.registrationVehiclePhoto,
      'personal-photo': locale.registrationPersonalPhoto,
    };
  }
}

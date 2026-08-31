import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../auth/presentation/widgets/registration_note_card.dart';
import '../../../auth/presentation/widgets/registration_scaffold.dart';
import '../../data/register_fake_data.dart';
import '../../domain/register_document.dart';
import '../widgets/register_document_upload_card.dart';

class RegisterUploadDocumentsScreen extends StatelessWidget {
  const RegisterUploadDocumentsScreen({
    super.key,
    required this.selectedImagePaths,
    required this.onDocumentTap,
    required this.onSubmit,
  });

  final Map<String, String> selectedImagePaths;
  final ValueChanged<RegisterDocument> onDocumentTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;
    final documents = RegisterFakeData.review.documents;
    final documentTitles = {
      'civil-card': locale.registrationCivilCard,
      'driving-license': locale.registrationDrivingLicense,
      'car-registration': locale.registrationCarRegistration,
      'vehicle-photo': locale.registrationVehiclePhoto,
      'personal-photo': locale.registrationPersonalPhoto,
    };
    final documentSubtitles = {
      'civil-card': locale.registrationCivilCardSubtitle,
      'driving-license': locale.registrationDrivingLicenseSubtitle,
      'car-registration': locale.registrationCarRegistrationSubtitle,
      'vehicle-photo': locale.registrationVehiclePhotoSubtitle,
      'personal-photo': locale.registrationPersonalPhotoSubtitle,
    };

    return RegistrationScaffold(
      title: locale.registrationDocuments,
      currentStep: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...documents.map(
            (document) => Padding(
              padding: const EdgeInsets.only(
                bottom: Spacing.registrationDocumentCardGap,
              ),
              child: RegisterDocumentUploadCard(
                document: document,
                title: documentTitles[document.id] ?? locale.registrationOther,
                subtitle:
                    documentSubtitles[document.id] ?? locale.registrationOther,
                selectedImagePath: selectedImagePaths[document.id],
                onTap: () => onDocumentTap(document),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          RegistrationNoteCard(
            title: locale.registrationImportantNote,
            text: locale.registrationUploadNote,
            icon: Icons.info_rounded,
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            height: Spacing.registrationSmallButtonHeight,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: Text(locale.registrationSubmitRequest),
            ),
          ),
          const SizedBox(height: Spacing.screenV),
        ],
      ),
    );
  }
}

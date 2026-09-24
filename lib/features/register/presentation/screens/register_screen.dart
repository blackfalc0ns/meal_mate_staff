import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../core/di/di.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/image_picker_helper.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../widgets/register_submission_shimmer.dart';
import '../../../account_status/domain/account_status_kind.dart';
import '../../domain/register_document.dart';
import '../../domain/register_review_data.dart';
import '../manager/driver_registration_event.dart';
import '../manager/driver_registration_state.dart';
import '../manager/driver_registration_view_model.dart';
import 'register_personal_data_screen.dart';
import 'register_review_screen.dart';
import 'register_upload_documents_screen.dart';
import 'register_vehicle_data_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.imagePicker,
    this.viewModel,
    this.phone,
    this.isResubmission = false,
    this.registrationId,
  });

  final ImagePicker? imagePicker;
  final DriverRegistrationViewModel? viewModel;
  final String? phone;
  final bool isResubmission;
  final String? registrationId;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final DriverRegistrationViewModel _viewModel;

  ImagePicker get _imagePicker => widget.imagePicker ?? ImagePicker();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<DriverRegistrationViewModel>();

    _viewModel.doIntent(const DriverRegistrationLoadRestaurantsEvent());
    _viewModel.doIntent(const DriverRegistrationLoadNationalitiesEvent());
    _viewModel.doIntent(const DriverRegistrationLoadVehicleTypesEvent());
    _viewModel.doIntent(const DriverRegistrationLoadVehicleColorsEvent());
    if (widget.phone != null && widget.phone!.isNotEmpty) {
      _viewModel.doIntent(
        DriverRegistrationSetDraftEvent(
          _viewModel.state.draft.copyWith(phone: widget.phone),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.close();
    }
    super.dispose();
  }

  Future<void> _pickDocumentImage(RegisterDocument document) async {
    final file = await ImagePickerHelper.pickImageWithSourceSheet(
      context,
      picker: _imagePicker,
    );

    if (file == null || !mounted) {
      return;
    }

    _viewModel.doIntent(
      DriverRegistrationUploadDocumentEvent(
        documentId: document.id,
        file: file,
      ),
    );
  }

  void _handleBack(int currentStep) {
    if (currentStep <= 1) {
      Navigator.of(context).maybePop();
      return;
    }

    _viewModel.doIntent(DriverRegistrationStepChangedEvent(currentStep - 1));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<DriverRegistrationViewModel, DriverRegistrationState>(
        listener: (context, state) {
          if (state.status == DriverRegistrationStatus.submissionSuccess ||
              state.status == DriverRegistrationStatus.resubmissionSuccess) {
            CustomSnackbar.showSuccess(
              context: context,
              message:
                  state.submissionResult?.message ??
                  context.localization.accountStatusTitle,
            );
            context.pushReplacementNamed(
              AppRoutes.accountStatus,
              arguments: AccountStatusKind.underReview,
            );
          }
        },
        builder: (context, state) {
          final formFailure = state.status == DriverRegistrationStatus.error
              ? state.failure
              : null;
          final stepFailure = state.currentStep == 2
              ? state.vehicleCatalogFailure ?? formFailure
              : formFailure;

          final content = switch (state.currentStep) {
            1 => RegisterPersonalDataScreen(
              initialData: state.draft.toPersonalData(),
              restaurants: state.restaurants,
              nationalities: state.nationalities,
              isLoadingCatalogs:
                  state.isLoadingRestaurants || state.isLoadingNationalities,
              failure: stepFailure,
              onPersonalDataChanged: (data) {
                _viewModel.doIntent(
                  DriverRegistrationPersonalDataUpdatedEvent(data),
                );
              },
              onContinue: () {
                _viewModel.doIntent(
                  const DriverRegistrationStepChangedEvent(2),
                );
              },
              onBackPressed: () => _handleBack(state.currentStep),
            ),
            2 => RegisterVehicleDataScreen(
              initialData: state.draft.toVehicleData(),
              vehicleTypes: state.vehicleTypes,
              vehicleColors: state.vehicleColors,
              vehicleModels: state.vehicleModels,
              isLoadingVehicleTypes: state.isLoadingVehicleTypes,
              isLoadingVehicleColors: state.isLoadingVehicleColors,
              isSearchingVehicleModels: state.isSearchingVehicleModels,
              selectedVehicleColor: state.selectedVehicleColor,
              ownsVehicle: state.ownsVehicle,
              failure: stepFailure,
              onRetryVehicleCatalog: () {
                _viewModel.doIntent(
                  const DriverRegistrationRetryVehicleCatalogEvent(),
                );
              },
              onVehicleModelQueryChanged: (search, vehicleType) {
                _viewModel.doIntent(
                  DriverRegistrationVehicleModelQueryChangedEvent(
                    search: search,
                    vehicleType: vehicleType,
                  ),
                );
              },
              onSearchVehicleModels: (search, vehicleType) {
                _viewModel.doIntent(
                  DriverRegistrationSearchVehicleModelsEvent(
                    search: search,
                    vehicleType: vehicleType,
                  ),
                );
              },
              onColorSelected: (color) {
                _viewModel.doIntent(
                  DriverRegistrationVehicleDataUpdatedEvent(
                    vehicleData: state.draft.toVehicleData(),
                    selectedColor: color,
                    ownsVehicle: state.ownsVehicle,
                  ),
                );
              },
              onOwnsVehicleChanged: (ownsVehicle) {
                _viewModel.doIntent(
                  DriverRegistrationVehicleDataUpdatedEvent(
                    vehicleData: state.draft.toVehicleData(),
                    selectedColor: state.selectedVehicleColor,
                    ownsVehicle: ownsVehicle,
                  ),
                );
              },
              onVehicleDataChanged: (data) {
                _viewModel.doIntent(
                  DriverRegistrationVehicleDataUpdatedEvent(
                    vehicleData: data,
                    selectedColor: state.selectedVehicleColor,
                    ownsVehicle: state.ownsVehicle,
                  ),
                );
              },
              onContinue: () {
                _viewModel.doIntent(
                  const DriverRegistrationStepChangedEvent(3),
                );
              },
              onBackPressed: () => _handleBack(state.currentStep),
            ),
            3 => RegisterUploadDocumentsScreen(
              documents: state.documents,
              selectedImagePaths: state.selectedImagePaths,
              failure: stepFailure,
              onDocumentTap: _pickDocumentImage,
              onSubmit: () {
                _viewModel.doIntent(
                  const DriverRegistrationStepChangedEvent(4),
                );
              },
              onBackPressed: () => _handleBack(state.currentStep),
            ),
            _ => RegisterReviewScreen(
              reviewData: RegisterReviewData(
                personal: state.draft.toPersonalData(),
                vehicle: state.draft.toVehicleData(),
                documents: state.documents,
              ),
              selectedImagePaths: state.selectedImagePaths,
              failure: stepFailure,
              onDocumentTap: _pickDocumentImage,
              onSubmit: () {
                if (widget.isResubmission &&
                    widget.registrationId != null &&
                    widget.registrationId!.isNotEmpty) {
                  _viewModel.doIntent(
                    DriverRegistrationResubmitEvent(
                      registrationId: widget.registrationId!,
                      resubmitData: state.draft.toResubmitEntity(),
                    ),
                  );
                } else {
                  _viewModel.doIntent(const DriverRegistrationSubmitEvent());
                }
              },
              onBackToEdit: () {
                _viewModel.doIntent(
                  const DriverRegistrationStepChangedEvent(3),
                );
              },
              onBackPressed: () => _handleBack(state.currentStep),
            ),
          };

          if (state.isSubmitting) {
            return Stack(
              children: [
                content,
                const ModalBarrier(dismissible: false, color: Colors.black26),
                const RegisterSubmissionShimmer(),
              ],
            );
          }

          return content;
        },
      ),
    );
  }
}

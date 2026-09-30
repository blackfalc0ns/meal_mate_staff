import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../core/di/di.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/helpers/image_picker_helper.dart';
import '../../../../core/widget/custom_progress_indecator.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../widgets/register_submission_shimmer.dart';
import '../../../account_status/domain/account_status_kind.dart';
import '../../domain/entities/driver_registration_draft_entity.dart';
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
      final initialDraft = _viewModel.state.draft.copyWith(phone: widget.phone);
      _viewModel.doIntent(
        DriverRegistrationSetDraftEvent(
          initialDraft,
          isOriginal: widget.isResubmission,
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
          } else if (state.status == DriverRegistrationStatus.error) {
            final is409 = state.failure?.exception.statusCode == 409 ||
                state.failure?.code == 'conflict' ||
                (state.errorMessage?.contains('ALREADY_APPROVED') ?? false) ||
                (state.errorMessage?.contains('ALREADY_REJECTED') ?? false) ||
                (state.errorMessage?.contains('INVALID_TRANSITION') ?? false);
            if (is409) {
              CustomSnackbar.showError(
                context: context,
                message: state.errorMessage ?? '',
              );
              context.pushReplacementNamed(
                AppRoutes.accountStatus,
                arguments: AccountStatusKind.underReview,
              );
            }
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
              isResubmission: widget.isResubmission,
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
              isSubmitEnabled:
                  !widget.isResubmission || state.hasResubmissionChanges,
              onSubmit: () {
                if (widget.isResubmission &&
                    widget.registrationId != null &&
                    widget.registrationId!.isNotEmpty) {
                  final sparseResubmit = state.draft.toSparseResubmitEntity(
                    original: state.originalDraft ??
                        DriverRegistrationDraftEntity(),
                    newlyUploadedDocumentIds: state.newlyUploadedDocumentIds,
                  );
                  if (sparseResubmit.isEmpty) {
                    CustomSnackbar.showError(
                      context: context,
                      message: context.localization.resubmitEmptyChanges,
                    );
                    return;
                  }
                  _viewModel.doIntent(
                    DriverRegistrationResubmitEvent(
                      registrationId: widget.registrationId!,
                      resubmitData: sparseResubmit,
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
                const Center(child: CustomProgressIndicator()),
              ],
            );
          }

          return content;
        },
      ),
    );
  }
}

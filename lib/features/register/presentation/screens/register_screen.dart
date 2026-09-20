import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/routing/app_routes.dart';
import '../../../../core/di/di.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/network/api_results.dart';
import '../../../../core/widget/custom_progress_indecator.dart';
import '../../../../core/widget/custom_snak_bar.dart';
import '../../../account_status/domain/account_status_kind.dart';
import '../../domain/entities/driver_file_upload_result_entity.dart';
import '../../domain/entities/driver_registration_draft_entity.dart';
import '../../domain/entities/driver_registration_result_entity.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/entities/driver_resubmit_entity.dart';
import '../../domain/repo/driver_registration_repository.dart';
import '../../domain/register_document.dart';
import '../../domain/register_review_data.dart';
import '../../domain/usecase/get_driver_restaurants_usecase.dart';
import '../../domain/usecase/resubmit_driver_registration_usecase.dart';
import '../../domain/usecase/submit_driver_registration_usecase.dart';
import '../../domain/usecase/upload_driver_document_usecase.dart';
import '../manager/driver_registration_event.dart';
import '../manager/driver_registration_state.dart';
import '../manager/driver_registration_view_model.dart';
import '../widgets/register_source_sheet.dart';
import 'register_personal_data_screen.dart';
import 'register_review_screen.dart';
import 'register_upload_documents_screen.dart';
import 'register_vehicle_data_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.imagePicker,
    this.viewModel,
  });

  final ImagePicker? imagePicker;
  final DriverRegistrationViewModel? viewModel;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _FakeRegistrationRepo implements DriverRegistrationRepository {
  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async =>
      ApiSuccessResult(data: []);

  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(
    File file,
  ) async =>
      ApiSuccessResult(
        data: const DriverFileUploadResultEntity(storageKey: 'key'),
      );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) async =>
      ApiSuccessResult(
        data: const DriverRegistrationResultEntity(
          registrationId: 'reg-1',
          restaurantId: 'res-1',
          restaurantName: 'Balance Box',
          phone: '+966501234567',
          status: 'Submitted',
          message: 'Submitted',
        ),
      );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) async =>
      ApiSuccessResult(
        data: const DriverRegistrationResultEntity(
          registrationId: 'reg-1',
          restaurantId: 'res-1',
          restaurantName: 'Balance Box',
          phone: '+966501234567',
          status: 'Submitted',
          message: 'Submitted',
        ),
      );
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final DriverRegistrationViewModel _viewModel;
  late final bool _isInternalViewModel;

  ImagePicker get _imagePicker => widget.imagePicker ?? ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isInternalViewModel = false;
    } else if (getIt.isRegistered<DriverRegistrationViewModel>()) {
      _viewModel = getIt<DriverRegistrationViewModel>();
      _isInternalViewModel = true;
    } else {
      final fakeRepo = _FakeRegistrationRepo();
      _viewModel = DriverRegistrationViewModel(
        getRestaurantsUseCase: GetDriverRestaurantsUseCase(fakeRepo),
        uploadDocumentUseCase: UploadDriverDocumentUseCase(fakeRepo),
        submitRegistrationUseCase: SubmitDriverRegistrationUseCase(fakeRepo),
        resubmitRegistrationUseCase:
            ResubmitDriverRegistrationUseCase(fakeRepo),
      );
      _isInternalViewModel = true;
    }

    _viewModel.doIntent(const DriverRegistrationLoadRestaurantsEvent());
  }

  @override
  void dispose() {
    if (_isInternalViewModel) {
      _viewModel.close();
    }
    super.dispose();
  }

  Future<void> _pickDocumentImage(RegisterDocument document) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const RegisterSourceSheet(),
    );

    if (source == null || !mounted) {
      return;
    }

    final image = await _imagePicker.pickImage(source: source);
    if (image == null || !mounted) {
      return;
    }

    _viewModel.doIntent(
      DriverRegistrationUploadDocumentEvent(
        documentId: document.id,
        file: File(image.path),
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
          if (state.status == DriverRegistrationStatus.submissionSuccess) {
            CustomSnackbar.showSuccess(
              context: context,
              message: state.submissionResult?.message ??
                  context.localization.accountStatusTitle,
            );
            context.pushReplacementNamed(
              AppRoutes.accountStatus,
              arguments: AccountStatusKind.underReview,
            );
          } else if (state.status == DriverRegistrationStatus.error &&
              state.errorMessage != null) {
            CustomSnackbar.showError(
              context: context,
              message: state.errorMessage!,
            );
          }
        },
        builder: (context, state) {
          final content = switch (state.currentStep) {
            1 => RegisterPersonalDataScreen(
                initialData: state.draft.toPersonalData(),
                restaurants: state.restaurants,
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
                selectedVehicleColor: state.selectedVehicleColor,
                ownsVehicle: state.ownsVehicle,
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
                onDocumentTap: _pickDocumentImage,
                onSubmit: () {
                  _viewModel.doIntent(
                    const DriverRegistrationSubmitEvent(),
                  );
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
                const ModalBarrier(
                  dismissible: false,
                  color: Colors.black26,
                ),
                const Center(
                  child: CustomProgressIndicator(),
                ),
              ],
            );
          }

          return content;
        },
      ),
    );
  }
}

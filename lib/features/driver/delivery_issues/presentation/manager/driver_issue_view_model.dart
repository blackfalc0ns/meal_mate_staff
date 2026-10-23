import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/network/failures.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../domain/entities/delivery_issue_entity.dart';
import '../../domain/entities/issue_photo_item.dart';
import '../../domain/usecase/report_driver_delay_usecase.dart';
import '../../domain/usecase/report_driver_issue_usecase.dart';
import '../../domain/usecase/upload_driver_issue_evidence_usecase.dart';
import 'driver_issue_event.dart';
import 'driver_issue_state.dart';

class DriverIssueViewModel extends Bloc<DriverIssueEvent, DriverIssueState> {
  DriverIssueViewModel({
    required ReportDriverIssueUseCase reportDriverIssueUseCase,
    required ReportDriverDelayUseCase reportDriverDelayUseCase,
    required UploadDriverIssueEvidenceUseCase uploadDriverIssueEvidenceUseCase,
    DeliveryIssueEntity? initialIssue,
  }) : _reportIssueUseCase = reportDriverIssueUseCase,
       _reportDelayUseCase = reportDriverDelayUseCase,
       _uploadEvidenceUseCase = uploadDriverIssueEvidenceUseCase,
       super(
         initialIssue == null
             ? const DriverIssueState()
             : DriverIssueState(
                 boxCode: initialIssue.boxCode,
                 customerName: initialIssue.customerName,
                 restaurantName: initialIssue.restaurantName,
                 area: initialIssue.area,
                 deliveryStatus: initialIssue.status,
                 mealsCountText: initialIssue.mealsCountText,
                 selectedReason: initialIssue.selectedReason,
                 notes: initialIssue.notes,
                 localPhotos: initialIssue.attachedPhotos,
                 deliveryContext: initialIssue.deliveryContext,
               ),
       ) {
    on<InitializeDriverIssueEvent>(_onInitialize);
    on<SelectDeliveryIssueReasonEvent>(_onSelectReason);
    on<UpdateDeliveryIssueNotesEvent>(_onUpdateNotes);
    on<AddDeliveryIssuePhotoEvent>(_onAddPhoto);
    on<AddIssuePhotoItemEvent>(_onAddPhotoItem);
    on<RetryIssuePhotoUploadEvent>(_onRetryPhotoUpload);
    on<RemoveIssuePhotoItemEvent>(_onRemovePhotoItem);
    on<ReuploadInvalidPhotosEvent>(_onReuploadInvalidPhotos);
    on<RemoveDeliveryIssuePhotoEvent>(_onRemovePhoto);
    on<SubmitDriverIssueEvent>(_onSubmitIssue);
    on<ReportDriverDelayEvent>(_onReportDelay);
    if (initialIssue != null && initialIssue.attachedPhotos.isNotEmpty) {
      add(InitializeDriverIssueEvent(initialIssue));
    }
  }

  final ReportDriverIssueUseCase _reportIssueUseCase;
  final ReportDriverDelayUseCase _reportDelayUseCase;
  final UploadDriverIssueEvidenceUseCase _uploadEvidenceUseCase;

  Future<void> _onInitialize(
    InitializeDriverIssueEvent event,
    Emitter<DriverIssueState> emit,
  ) async {
    final issue = event.initialIssue;
    emit(
      state.copyWith(
        boxCode: issue.boxCode,
        customerName: issue.customerName,
        restaurantName: issue.restaurantName,
        area: issue.area,
        deliveryStatus: issue.status,
        mealsCountText: issue.mealsCountText,
        selectedReason: issue.selectedReason,
        notes: issue.notes,
        localPhotos: issue.attachedPhotos,
        photoItems: issue.attachedPhotos
            .where((path) => !path.startsWith('assets/'))
            .map((path) {
              final isStorageKey = path.startsWith(
                'uploads/drivers/issue-evidence/',
              );
              return IssuePhotoItem(
                id: path,
                localPath: path,
                status: isStorageKey
                    ? IssuePhotoStatus.success
                    : IssuePhotoStatus.uploading,
                storageKey: isStorageKey ? path : null,
              );
            })
            .toList(),
        uploadedStorageKeys: const [],
        deliveryContext: issue.deliveryContext,
        status: DriverIssueStatus.initial,
        errorMessage: null,
      ),
    );
    final pending = state.photoItems.where((item) => item.isUploading).toList();
    for (final item in pending) {
      await _uploadSinglePhoto(item.id, item.localPath, emit);
    }
  }

  void _onSelectReason(
    SelectDeliveryIssueReasonEvent event,
    Emitter<DriverIssueState> emit,
  ) {
    emit(
      state.copyWith(
        selectedReason: event.reason,
        status: DriverIssueStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void _onUpdateNotes(
    UpdateDeliveryIssueNotesEvent event,
    Emitter<DriverIssueState> emit,
  ) {
    emit(
      state.copyWith(
        notes: event.notes,
        status: DriverIssueStatus.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onAddPhoto(
    AddDeliveryIssuePhotoEvent event,
    Emitter<DriverIssueState> emit,
  ) async {
    final isLocal =
        !event.photoPath.startsWith('assets/') &&
        File(event.photoPath).existsSync();
    final item = IssuePhotoItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_${state.photoItems.length}',
      localPath: event.photoPath,
      status: isLocal ? IssuePhotoStatus.uploading : IssuePhotoStatus.success,
      storageKey: isLocal ? null : event.photoPath,
    );
    await _onAddPhotoItem(AddIssuePhotoItemEvent(item), emit);
  }

  Future<void> _onAddPhotoItem(
    AddIssuePhotoItemEvent event,
    Emitter<DriverIssueState> emit,
  ) async {
    if (state.photoItems.length >= 3) {
      emit(state.copyWith(errorMessage: 'Maximum 3 photos allowed'));
      return;
    }

    final item = event.item;
    final currentItems = [...state.photoItems, item];
    emit(
      state.copyWith(
        photoItems: currentItems,
        localPhotos: currentItems.map((p) => p.localPath).toList(),
        status: DriverIssueStatus.initial,
        errorMessage: null,
      ),
    );

    if (item.status == IssuePhotoStatus.uploading) {
      await _uploadSinglePhoto(item.id, item.localPath, emit);
    }
  }

  Future<void> _onRetryPhotoUpload(
    RetryIssuePhotoUploadEvent event,
    Emitter<DriverIssueState> emit,
  ) async {
    final index = state.photoItems.indexWhere((p) => p.id == event.photoId);
    if (index == -1) return;

    final item = state.photoItems[index];
    _updatePhotoStatus(
      event.photoId,
      status: IssuePhotoStatus.uploading,
      emit: emit,
    );

    await _uploadSinglePhoto(item.id, item.localPath, emit);
  }

  void _onRemovePhotoItem(
    RemoveIssuePhotoItemEvent event,
    Emitter<DriverIssueState> emit,
  ) {
    final updated = state.photoItems
        .where((p) => p.id != event.photoId)
        .toList();
    final successfulKeys = updated
        .where(
          (p) =>
              p.isSuccess &&
              p.storageKey != null &&
              p.storageKey!.trim().isNotEmpty,
        )
        .map((p) => p.storageKey!.trim())
        .toList();

    emit(
      state.copyWith(
        photoItems: updated,
        localPhotos: updated.map((p) => p.localPath).toList(),
        uploadedStorageKeys: successfulKeys,
      ),
    );
  }

  Future<void> _onReuploadInvalidPhotos(
    ReuploadInvalidPhotosEvent event,
    Emitter<DriverIssueState> emit,
  ) async {
    final failedItems = state.photoItems
        .where((p) => p.isFailed || !p.isSuccess)
        .toList();
    for (final item in failedItems) {
      _updatePhotoStatus(
        item.id,
        status: IssuePhotoStatus.uploading,
        emit: emit,
      );
      await _uploadSinglePhoto(item.id, item.localPath, emit);
    }
  }

  void _onRemovePhoto(
    RemoveDeliveryIssuePhotoEvent event,
    Emitter<DriverIssueState> emit,
  ) {
    if (event.index >= 0 && event.index < state.photoItems.length) {
      _onRemovePhotoItem(
        RemoveIssuePhotoItemEvent(state.photoItems[event.index].id),
        emit,
      );
    } else if (event.index >= 0 && event.index < state.localPhotos.length) {
      final updated = List<String>.from(state.localPhotos)
        ..removeAt(event.index);
      emit(
        state.copyWith(
          localPhotos: updated,
          status: DriverIssueStatus.initial,
          errorMessage: null,
        ),
      );
    }
  }

  Future<void> _uploadSinglePhoto(
    String photoId,
    String localPath,
    Emitter<DriverIssueState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('[IssueEvidence v2] upload_start');
    }
    final file = File(localPath);
    if (!file.existsSync()) {
      _updatePhotoStatus(
        photoId,
        status: IssuePhotoStatus.failed,
        errorMessage: 'الملف غير موجود',
        emit: emit,
      );
      return;
    }

    final result = await _uploadEvidenceUseCase(file);
    switch (result) {
      case ApiSuccessResult<String>(:final data):
        if (kDebugMode) {
          debugPrint(
            '[IssueEvidence v2] upload_success hasKey=${data.trim().isNotEmpty}',
          );
        }
        _updatePhotoStatus(
          photoId,
          status: IssuePhotoStatus.success,
          storageKey: data,
          emit: emit,
        );
      case ApiErrorResult<String>(:final failure):
        if (kDebugMode) {
          debugPrint(
            '[IssueEvidence v2] upload_failed status=${failure.exception.statusCode} code=${failure.exception.backendErrorCode}',
          );
        }
        _updatePhotoStatus(
          photoId,
          status: IssuePhotoStatus.failed,
          errorMessage: failure.errorMessage,
          emit: emit,
        );
    }
  }

  void _updatePhotoStatus(
    String photoId, {
    required IssuePhotoStatus status,
    String? storageKey,
    String? errorMessage,
    required Emitter<DriverIssueState> emit,
  }) {
    final index = state.photoItems.indexWhere((p) => p.id == photoId);
    if (index == -1) return;

    final updated = state.photoItems[index].copyWith(
      status: status,
      storageKey: storageKey,
      errorMessage: errorMessage,
      clearErrorMessage: status == IssuePhotoStatus.success,
      clearStorageKey: status == IssuePhotoStatus.failed,
    );

    final newItems = List<IssuePhotoItem>.from(state.photoItems)
      ..[index] = updated;
    final successfulKeys = newItems
        .where(
          (p) =>
              p.isSuccess &&
              p.storageKey != null &&
              p.storageKey!.trim().isNotEmpty,
        )
        .map((p) => p.storageKey!.trim())
        .toList();

    emit(
      state.copyWith(
        photoItems: newItems,
        localPhotos: newItems.map((p) => p.localPath).toList(),
        uploadedStorageKeys: successfulKeys,
      ),
    );
  }

  Future<void> _onSubmitIssue(
    SubmitDriverIssueEvent event,
    Emitter<DriverIssueState> emit,
  ) async {
    if (state.isLoading) return;

    if (state.hasUploadingPhotos) {
      emit(
        state.copyWith(
          status: DriverIssueStatus.error,
          errorMessage: 'يرجى الانتظار حتى يكتمل رفع الصور',
        ),
      );
      return;
    }

    if (state.hasFailedPhotos) {
      emit(
        state.copyWith(
          status: DriverIssueStatus.error,
          errorMessage: 'تعذر رفع بعض الصور، يرجى إعادة المحاولة أو حذفها',
        ),
      );
      return;
    }

    final validKeys = state.validStorageKeys;
    if (kDebugMode) {
      debugPrint(
        '[IssueEvidence v2] submit selected=${event.selectedPhotoCount} items=${state.photoItems.length} keys=${validKeys.length}',
      );
    }
    if ((event.selectedPhotoCount != null &&
            event.selectedPhotoCount != validKeys.length) ||
        state.photoItems.length != validKeys.length) {
      final failure = Failure(
        errorMessage:
            'لم يكتمل ربط الصور المختارة. أعد رفع الصورة أو احذفها قبل الإرسال.',
        code: 'ISSUE_PHOTOS_NOT_READY',
      );
      emit(
        state.copyWith(
          status: DriverIssueStatus.error,
          failure: failure,
          errorMessage: failure.errorMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DriverIssueStatus.loading,
        uploadedStorageKeys: validKeys,
        failure: null,
        errorMessage: null,
      ),
    );

    final reportResult = await _reportIssueUseCase(
      boxId: event.boxId,
      reason: state.selectedReason,
      description: state.notes,
      severity: 'Medium',
      photoStorageKeys: validKeys,
    );

    switch (reportResult) {
      case ApiSuccessResult<String>(:final data):
        emit(
          state.copyWith(
            status: DriverIssueStatus.success,
            reportedIssueId: data,
            errorMessage: null,
            failure: null,
          ),
        );
      case ApiErrorResult<String>(:final failure):
        final isPhotoNotFound =
            failure.code == 'driver.issue.photo_not_found' ||
            failure.exception.backendErrorCode ==
                'driver.issue.photo_not_found';

        if (isPhotoNotFound) {
          final resetItems = state.photoItems.map((p) {
            return p.copyWith(
              status: IssuePhotoStatus.failed,
              clearStorageKey: true,
              errorMessage: failure.errorMessage,
            );
          }).toList();

          emit(
            state.copyWith(
              status: DriverIssueStatus.error,
              errorMessage: failure.errorMessage,
              failure: failure,
              photoItems: resetItems,
              uploadedStorageKeys: const [],
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: DriverIssueStatus.error,
            errorMessage: failure.errorMessage,
            failure: failure,
          ),
        );
    }
  }

  Future<void> _onReportDelay(
    ReportDriverDelayEvent event,
    Emitter<DriverIssueState> emit,
  ) async {
    emit(state.copyWith(status: DriverIssueStatus.loading, failure: null));

    final result = await _reportDelayUseCase(
      boxId: event.boxId,
      delayMinutes: event.delayMinutes,
      reason: event.reason,
    );

    switch (result) {
      case ApiSuccessResult<bool>():
        emit(
          state.copyWith(
            status: DriverIssueStatus.delaySuccess,
            errorMessage: null,
            failure: null,
          ),
        );
      case ApiErrorResult<bool>(:final failure):
        emit(
          state.copyWith(
            status: DriverIssueStatus.error,
            errorMessage: failure.errorMessage,
            failure: failure,
          ),
        );
    }
  }
}

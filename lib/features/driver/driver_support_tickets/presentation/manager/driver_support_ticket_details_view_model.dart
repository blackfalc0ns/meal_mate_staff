import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../../../delivery_issues/domain/usecase/upload_driver_issue_evidence_usecase.dart';
import '../../../orders/data/realtime/driver_orders_realtime_client.dart';
import '../../../orders/domain/entities/driver_orders_realtime_event.dart';
import '../../domain/usecase/add_driver_support_issue_photos_usecase.dart';
import '../../domain/usecase/get_driver_support_issue_details_usecase.dart';
import 'driver_support_ticket_details_event.dart';
import 'driver_support_ticket_details_state.dart';

@injectable
class DriverSupportTicketDetailsViewModel
    extends Cubit<DriverSupportTicketDetailsState> {
  DriverSupportTicketDetailsViewModel({
    required GetDriverSupportIssueDetailsUseCase
    getDriverSupportIssueDetailsUseCase,
    required AddDriverSupportIssuePhotosUseCase
    addDriverSupportIssuePhotosUseCase,
    required UploadDriverIssueEvidenceUseCase uploadDriverIssueEvidenceUseCase,
    DriverOrdersRealtimeClient? driverOrdersRealtimeClient,
  }) : _getDetailsUseCase = getDriverSupportIssueDetailsUseCase,
       _addPhotosUseCase = addDriverSupportIssuePhotosUseCase,
       _uploadEvidenceUseCase = uploadDriverIssueEvidenceUseCase,
       _realtimeClient = driverOrdersRealtimeClient,
       super(const DriverSupportTicketDetailsState()) {
    _initRealtime();
  }

  final GetDriverSupportIssueDetailsUseCase _getDetailsUseCase;
  final AddDriverSupportIssuePhotosUseCase _addPhotosUseCase;
  final UploadDriverIssueEvidenceUseCase _uploadEvidenceUseCase;
  final DriverOrdersRealtimeClient? _realtimeClient;

  StreamSubscription<DriverOrdersRealtimeEvent>? _eventsSub;
  StreamSubscription<bool>? _connectionSub;
  Timer? _realtimeDebounceTimer;
  DateTime? _lastEvidenceRefresh;

  void _initRealtime() {
    final client = _realtimeClient;
    if (client == null) return;

    _eventsSub = client.events.listen((event) {
      if (isClosed) return;
      if (event is DriverSupportIssueUpdatedEvent) {
        if (state.issueId.isEmpty ||
            event.issueId == null ||
            event.issueId == state.issueId) {
          doIntent(OnRealtimeDetailsUpdatedEvent(issueId: event.issueId));
        }
      } else if (event is DriverConnectionEstablishedEvent) {
        doIntent(const RefreshDriverSupportTicketDetailsEvent());
      }
    });

    _connectionSub = client.connectionStatus.listen((connected) {
      if (isClosed) return;
      if (connected) {
        doIntent(const RefreshDriverSupportTicketDetailsEvent());
      }
    });
  }

  void doIntent(DriverSupportTicketDetailsEvent event) {
    if (isClosed) return;
    switch (event) {
      case LoadDriverSupportTicketDetailsEvent(:final issueId):
        unawaited(_loadDetails(issueId));
      case RefreshDriverSupportTicketDetailsEvent():
        _lastEvidenceRefresh = null;
        unawaited(_refreshDetails());
      case RefreshSupportEvidenceUrlsEvent():
        if ((_lastEvidenceRefresh == null ||
                DateTime.now().difference(_lastEvidenceRefresh!) >=
                    const Duration(minutes: 14)) &&
            !state.isLoading &&
            !state.isRefreshing &&
            state.details != null) {
          _lastEvidenceRefresh = DateTime.now();
          unawaited(_refreshDetails());
        }
      case AddDriverSupportTicketPhotoEvent(:final file):
        unawaited(_addPhoto(file));
      case RetryAttachPhotosEvent():
        unawaited(_attachPendingPhotos());
      case RetryDriverSupportTicketDetailsEvent():
        _onRetry();
      case OnRealtimeDetailsUpdatedEvent():
        _handleRealtimeUpdated();
      case ClearDetailsFeedbackEvent():
        _clearFeedback();
    }
  }

  void _clearFeedback() {
    emit(state.copyWith(clearFailure: true, clearActionFailure: true));
  }

  Future<void> _loadDetails(String issueId) async {
    final cleanId = issueId.trim();
    if (cleanId.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: Failure(
            errorMessage: 'معرف البلاغ غير صالح',
            code: 'DRIVER_SUPPORT_ISSUE_INVALID_ID',
          ),
        ),
      );
      return;
    }

    _lastEvidenceRefresh = null;
    emit(
      state.copyWith(
        isLoading: true,
        issueId: cleanId,
        clearFailure: true,
        clearActionFailure: true,
      ),
    );

    final result = await _getDetailsUseCase(cleanId);
    if (isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(isLoading: false, details: data, clearFailure: true),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _refreshDetails() async {
    if (state.issueId.isEmpty || state.isRefreshing || state.isLoading) return;

    emit(state.copyWith(isRefreshing: true));

    final result = await _getDetailsUseCase(state.issueId);
    if (isClosed) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isRefreshing: false,
            details: data,
            clearFailure: true,
            clearActionFailure: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isRefreshing: false, actionFailure: failure));
    }
  }

  Future<void> _addPhoto(File file) async {
    if (state.isActionInProgress) return;

    final currentDetails = state.details;
    if (currentDetails != null && currentDetails.isTerminal) {
      emit(
        state.copyWith(
          actionFailure: Failure(
            errorMessage: 'البلاغ منتهٍ ولا يقبل صوراً جديدة',
            code: 'DRIVER_SUPPORT_ISSUE_TERMINAL',
          ),
        ),
      );
      return;
    }

    final existingCount = currentDetails?.evidenceUrls.length ?? 0;
    if (existingCount + state.pendingStorageKeys.length >= 3) {
      emit(
        state.copyWith(
          actionFailure: Failure(
            errorMessage: 'الحد الأقصى للصور 3 صور',
            code: 'DRIVER_SUPPORT_PHOTO_LIMIT',
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(isUploadingPhoto: true, clearActionFailure: true));

    final uploadResult = await _uploadEvidenceUseCase(file);
    if (isClosed) return;

    switch (uploadResult) {
      case ApiSuccessResult(:final data):
        final newStorageKey = data.trim();
        final updatedPending = [...state.pendingStorageKeys, newStorageKey];
        emit(
          state.copyWith(
            isUploadingPhoto: false,
            pendingStorageKeys: updatedPending,
          ),
        );
        await _attachPendingPhotos();

      case ApiErrorResult(:final failure):
        emit(state.copyWith(isUploadingPhoto: false, actionFailure: failure));
    }
  }

  Future<void> _attachPendingPhotos() async {
    if (state.pendingStorageKeys.isEmpty || state.issueId.isEmpty) return;

    emit(state.copyWith(isAttachingPhotos: true, clearActionFailure: true));

    final result = await _addPhotosUseCase(
      issueId: state.issueId,
      storageKeys: state.pendingStorageKeys,
    );

    if (isClosed) return;

    switch (result) {
      case ApiSuccessResult():
        emit(
          state.copyWith(
            isAttachingPhotos: false,
            pendingStorageKeys: const [],
            clearActionFailure: true,
          ),
        );
        // Refresh details to ensure server timeline and evidenceUrls match
        unawaited(_refreshDetails());

      case ApiErrorResult(:final failure):
        // If terminal or photo limit, refresh details to sync state
        if (failure.code == 'DRIVER_SUPPORT_ISSUE_TERMINAL' ||
            failure.exception.backendErrorCode ==
                'DRIVER_SUPPORT_ISSUE_TERMINAL' ||
            failure.code == 'DRIVER_SUPPORT_PHOTO_LIMIT' ||
            failure.exception.backendErrorCode ==
                'DRIVER_SUPPORT_PHOTO_LIMIT') {
          unawaited(_refreshDetails());
        }

        emit(state.copyWith(isAttachingPhotos: false, actionFailure: failure));
    }
  }

  void _onRetry() {
    if (state.failure != null) {
      unawaited(_loadDetails(state.issueId));
    } else if (state.actionFailure != null &&
        state.pendingStorageKeys.isNotEmpty) {
      unawaited(_attachPendingPhotos());
    } else {
      unawaited(_refreshDetails());
    }
  }

  void _handleRealtimeUpdated() {
    _realtimeDebounceTimer?.cancel();
    _realtimeDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (isClosed) return;
      unawaited(_refreshDetails());
    });
  }

  @override
  Future<void> close() {
    _realtimeDebounceTimer?.cancel();
    unawaited(_eventsSub?.cancel());
    unawaited(_connectionSub?.cancel());
    return super.close();
  }
}

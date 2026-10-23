import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_support_ticket_details_entity.dart';

class DriverSupportTicketDetailsState {
  const DriverSupportTicketDetailsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isUploadingPhoto = false,
    this.isAttachingPhotos = false,
    this.issueId = '',
    this.details,
    this.failure,
    this.actionFailure,
    this.pendingStorageKeys = const [],
  });

  final bool isLoading;
  final bool isRefreshing;
  final bool isUploadingPhoto;
  final bool isAttachingPhotos;
  final String issueId;
  final DriverSupportTicketDetailsEntity? details;
  final Failure? failure;
  final Failure? actionFailure;
  final List<String> pendingStorageKeys;

  bool get hasData => details != null;
  bool get isActionInProgress => isUploadingPhoto || isAttachingPhotos;

  DriverSupportTicketDetailsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isUploadingPhoto,
    bool? isAttachingPhotos,
    String? issueId,
    DriverSupportTicketDetailsEntity? details,
    Failure? failure,
    bool clearFailure = false,
    Failure? actionFailure,
    bool clearActionFailure = false,
    List<String>? pendingStorageKeys,
  }) {
    return DriverSupportTicketDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isAttachingPhotos: isAttachingPhotos ?? this.isAttachingPhotos,
      issueId: issueId ?? this.issueId,
      details: details ?? this.details,
      failure: clearFailure ? null : (failure ?? this.failure),
      actionFailure:
          clearActionFailure ? null : (actionFailure ?? this.actionFailure),
      pendingStorageKeys: pendingStorageKeys ?? this.pendingStorageKeys,
    );
  }
}

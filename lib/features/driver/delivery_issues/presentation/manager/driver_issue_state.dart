import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../domain/entities/delivery_issue_entity.dart';
import '../../domain/entities/delivery_issue_reason.dart';
import '../../domain/entities/reassignment_delivery_context_entity.dart';

import '../../domain/entities/issue_photo_item.dart';

enum DriverIssueStatus {
  initial,
  loading,
  uploadingPhotos,
  success,
  delaySuccess,
  error,
}

class DriverIssueState {
  const DriverIssueState({
    this.status = DriverIssueStatus.initial,
    this.selectedReason = DeliveryIssueReason.customerNoAnswer,
    this.notes = '',
    this.localPhotos = const [],
    this.photoItems = const [],
    this.uploadedStorageKeys = const [],
    this.boxCode = '',
    this.customerName = '',
    this.restaurantName = '',
    this.area = '',
    this.deliveryStatus = '',
    this.mealsCountText = '',
    this.deliveryContext,
    this.errorMessage,
    this.failure,
    this.reportedIssueId,
  });

  final DriverIssueStatus status;
  final DeliveryIssueReason selectedReason;
  final String notes;
  final List<String> localPhotos;
  final List<IssuePhotoItem> photoItems;
  final List<String> uploadedStorageKeys;
  final String boxCode;
  final String customerName;
  final String restaurantName;
  final String area;
  final String deliveryStatus;
  final String mealsCountText;
  final ReassignmentDeliveryContextEntity? deliveryContext;
  final String? errorMessage;
  final Failure? failure;
  final String? reportedIssueId;

  bool get isLoading =>
      status == DriverIssueStatus.loading ||
      status == DriverIssueStatus.uploadingPhotos;

  bool get isSubmitting => isLoading;
  bool get isSuccess =>
      status == DriverIssueStatus.success ||
      status == DriverIssueStatus.delaySuccess;
  bool get isFailure => status == DriverIssueStatus.error;
  List<String> get photos =>
      photoItems.isNotEmpty ? photoItems.map((p) => p.localPath).toList() : localPhotos;
  bool get hasUploadingPhotos => photoItems.any((p) => p.isUploading);
  bool get hasFailedPhotos => photoItems.any((p) => p.isFailed);
  List<String> get validStorageKeys => photoItems
      .where((p) => p.isSuccess && p.storageKey != null && p.storageKey!.trim().isNotEmpty)
      .map((p) => p.storageKey!.trim())
      .toList();
  String? get submittedIssueId => reportedIssueId;

  DriverIssueState copyWith({
    DriverIssueStatus? status,
    DeliveryIssueReason? selectedReason,
    String? notes,
    List<String>? localPhotos,
    List<IssuePhotoItem>? photoItems,
    List<String>? uploadedStorageKeys,
    String? boxCode,
    String? customerName,
    String? restaurantName,
    String? area,
    String? deliveryStatus,
    String? mealsCountText,
    ReassignmentDeliveryContextEntity? deliveryContext,
    String? errorMessage,
    Failure? failure,
    String? reportedIssueId,
  }) {
    return DriverIssueState(
      status: status ?? this.status,
      selectedReason: selectedReason ?? this.selectedReason,
      notes: notes ?? this.notes,
      localPhotos: localPhotos ?? this.localPhotos,
      photoItems: photoItems ?? this.photoItems,
      uploadedStorageKeys: uploadedStorageKeys ?? this.uploadedStorageKeys,
      boxCode: boxCode ?? this.boxCode,
      customerName: customerName ?? this.customerName,
      restaurantName: restaurantName ?? this.restaurantName,
      area: area ?? this.area,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      mealsCountText: mealsCountText ?? this.mealsCountText,
      deliveryContext: deliveryContext ?? this.deliveryContext,
      errorMessage: errorMessage,
      failure: failure,
      reportedIssueId: reportedIssueId ?? this.reportedIssueId,
    );
  }

  DeliveryIssueEntity toEntity() {
    return DeliveryIssueEntity(
      boxCode: boxCode,
      customerName: customerName,
      restaurantName: restaurantName,
      area: area,
      status: deliveryStatus,
      mealsCountText: mealsCountText,
      selectedReason: selectedReason,
      notes: notes,
      attachedPhotos: localPhotos,
      deliveryContext: deliveryContext,
    );
  }
}

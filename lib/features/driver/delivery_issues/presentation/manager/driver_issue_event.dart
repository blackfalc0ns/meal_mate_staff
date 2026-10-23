import '../../domain/entities/delivery_issue_entity.dart';
import '../../domain/entities/delivery_issue_reason.dart';

import '../../domain/entities/issue_photo_item.dart';

sealed class DriverIssueEvent {
  const DriverIssueEvent();
}

class InitializeDriverIssueEvent extends DriverIssueEvent {
  const InitializeDriverIssueEvent(this.initialIssue);

  final DeliveryIssueEntity initialIssue;
}

class SelectDeliveryIssueReasonEvent extends DriverIssueEvent {
  const SelectDeliveryIssueReasonEvent(this.reason);

  final DeliveryIssueReason reason;
}

class UpdateDeliveryIssueNotesEvent extends DriverIssueEvent {
  const UpdateDeliveryIssueNotesEvent(this.notes);

  final String notes;
}

class AddDeliveryIssuePhotoEvent extends DriverIssueEvent {
  const AddDeliveryIssuePhotoEvent(this.photoPath);

  final String photoPath;
}

class AddIssuePhotoItemEvent extends DriverIssueEvent {
  const AddIssuePhotoItemEvent(this.item);

  final IssuePhotoItem item;
}

class RetryIssuePhotoUploadEvent extends DriverIssueEvent {
  const RetryIssuePhotoUploadEvent(this.photoId);

  final String photoId;
}

class RemoveIssuePhotoItemEvent extends DriverIssueEvent {
  const RemoveIssuePhotoItemEvent(this.photoId);

  final String photoId;
}

class ReuploadInvalidPhotosEvent extends DriverIssueEvent {
  const ReuploadInvalidPhotosEvent();
}

class RemoveDeliveryIssuePhotoEvent extends DriverIssueEvent {
  const RemoveDeliveryIssuePhotoEvent(this.index);

  final int index;
}

class SubmitDriverIssueEvent extends DriverIssueEvent {
  const SubmitDriverIssueEvent({required this.boxId, this.selectedPhotoCount});

  final String boxId;
  final int? selectedPhotoCount;
}

class ReportDriverDelayEvent extends DriverIssueEvent {
  const ReportDriverDelayEvent({
    required this.boxId,
    required this.delayMinutes,
    this.reason,
  });

  final String boxId;
  final int delayMinutes;
  final String? reason;
}

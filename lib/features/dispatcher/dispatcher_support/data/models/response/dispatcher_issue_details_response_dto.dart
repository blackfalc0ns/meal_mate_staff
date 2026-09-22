import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_issue_details_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherIssueDetailsResponseDto {
  const DispatcherIssueDetailsResponseDto({
    this.issueId,
    this.id,
    this.title,
    this.category,
    this.categoryLabel,
    this.categoryColor,
    this.createdAt,
    this.createdAtUtc,
    this.reportedTimeText,
    this.timeAgo,
    this.status,
    this.statusLabel,
    this.boxCode,
    this.taskNumber,
    this.area,
    this.affectedBoxesCount,
    this.affectedBoxesText,
    this.priority,
    this.priorityText,
    this.priorityLabel,
    this.priorityColor,
    this.metadata,
    this.driver,
    this.description,
    this.evidencePhotos,
    this.attachments,
    this.tripInfo,
    this.resolution,
  });

  factory DispatcherIssueDetailsResponseDto.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DispatcherIssueDetailsResponseDtoFromJson(json);

  final String? issueId;
  final String? id;
  final String? title;
  final String? category;
  final String? categoryLabel;
  final String? categoryColor;
  final String? createdAt;
  final String? createdAtUtc;
  final String? reportedTimeText;
  final String? timeAgo;
  final String? status;
  final String? statusLabel;
  final String? boxCode;
  final String? taskNumber;
  final String? area;
  final int? affectedBoxesCount;
  final String? affectedBoxesText;
  final String? priority;
  final String? priorityText;
  final String? priorityLabel;
  final String? priorityColor;
  final DispatcherIssueMetadataDto? metadata;
  final DispatcherIssueDriverDto? driver;
  final String? description;
  final List<DispatcherIssueAttachmentDto>? evidencePhotos;
  final List<DispatcherIssueAttachmentDto>? attachments;
  final DispatcherIssueTripDto? tripInfo;
  final DispatcherIssueResolutionDto? resolution;
}

@JsonSerializable(createToJson: false)
class DispatcherIssueMetadataDto {
  const DispatcherIssueMetadataDto({
    this.boxCode,
    this.taskNumber,
    this.area,
    this.affectedBoxesCount,
    this.affectedBoxesText,
    this.priority,
    this.priorityText,
    this.priorityLabel,
    this.priorityColor,
  });

  factory DispatcherIssueMetadataDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherIssueMetadataDtoFromJson(json);

  final String? boxCode;
  final String? taskNumber;
  final String? area;
  final int? affectedBoxesCount;
  final String? affectedBoxesText;
  final String? priority;
  final String? priorityText;
  final String? priorityLabel;
  final String? priorityColor;
}

@JsonSerializable(createToJson: false)
class DispatcherIssueDriverDto {
  const DispatcherIssueDriverDto({
    this.id,
    this.driverId,
    this.name,
    this.driverName,
    this.fullName,
    this.code,
    this.driverCode,
    this.avatarUrl,
    this.driverAvatar,
    this.phoneNumber,
    this.phone,
    this.isOnline,
    this.status,
    this.statusText,
    this.statusLabel,
    this.statusColor,
    this.subStatus,
    this.driverSubStatus,
    this.unavailabilityReason,
    this.unavailabilityReasonText,
    this.vehicleInfo,
    this.rating,
  });

  factory DispatcherIssueDriverDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherIssueDriverDtoFromJson(json);

  final String? id;
  final String? driverId;
  final String? name;
  final String? driverName;
  final String? fullName;
  final String? code;
  final String? driverCode;
  final String? avatarUrl;
  final String? driverAvatar;
  final String? phoneNumber;
  final String? phone;
  final bool? isOnline;
  final String? status;
  final String? statusText;
  final String? statusLabel;
  final String? statusColor;
  final String? subStatus;
  final String? driverSubStatus;
  final String? unavailabilityReason;
  final String? unavailabilityReasonText;
  final String? vehicleInfo;
  final double? rating;
}

@JsonSerializable(createToJson: false)
class DispatcherIssueAttachmentDto {
  const DispatcherIssueAttachmentDto({
    this.id,
    this.url,
    this.thumbnailUrl,
    this.uploadedAt,
    this.uploadedAtUtc,
    this.orderNumber,
  });

  factory DispatcherIssueAttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherIssueAttachmentDtoFromJson(json);

  final String? id;
  final String? url;
  final String? thumbnailUrl;
  final String? uploadedAt;
  final String? uploadedAtUtc;
  final int? orderNumber;
}

@JsonSerializable(createToJson: false)
class DispatcherIssueTripDto {
  const DispatcherIssueTripDto({
    this.clientName,
    this.customerName,
    this.mealsCount,
    this.mealsCountText,
    this.expectedDeliveryTime,
    this.expectedDeliveryTimeText,
    this.pickupLocation,
    this.dropoffLocation,
    this.deliveryAddress,
    this.orderId,
  });

  factory DispatcherIssueTripDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherIssueTripDtoFromJson(json);

  final String? clientName;
  final String? customerName;
  final int? mealsCount;
  final String? mealsCountText;
  final String? expectedDeliveryTime;
  final String? expectedDeliveryTimeText;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? deliveryAddress;
  final String? orderId;
}

@JsonSerializable(createToJson: false)
class DispatcherIssueResolutionDto {
  const DispatcherIssueResolutionDto({
    this.resolutionNotes,
    this.notes,
    this.resolvedBy,
    this.resolvedAt,
    this.resolvedAtUtc,
    this.resolvedAtText,
    this.resolvedAction,
    this.resolvedActionLabel,
  });

  factory DispatcherIssueResolutionDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherIssueResolutionDtoFromJson(json);

  final String? resolutionNotes;
  final String? notes;
  final String? resolvedBy;
  final String? resolvedAt;
  final String? resolvedAtUtc;
  final String? resolvedAtText;
  final String? resolvedAction;
  final String? resolvedActionLabel;
}

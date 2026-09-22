// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_issue_details_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherIssueDetailsResponseDto _$DispatcherIssueDetailsResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherIssueDetailsResponseDto(
  issueId: json['issueId'] as String?,
  id: json['id'] as String?,
  title: json['title'] as String?,
  category: json['category'] as String?,
  categoryLabel: json['categoryLabel'] as String?,
  categoryColor: json['categoryColor'] as String?,
  createdAt: json['createdAt'] as String?,
  createdAtUtc: json['createdAtUtc'] as String?,
  reportedTimeText: json['reportedTimeText'] as String?,
  timeAgo: json['timeAgo'] as String?,
  status: json['status'] as String?,
  statusLabel: json['statusLabel'] as String?,
  boxCode: json['boxCode'] as String?,
  taskNumber: json['taskNumber'] as String?,
  area: json['area'] as String?,
  affectedBoxesCount: (json['affectedBoxesCount'] as num?)?.toInt(),
  affectedBoxesText: json['affectedBoxesText'] as String?,
  priority: json['priority'] as String?,
  priorityText: json['priorityText'] as String?,
  priorityLabel: json['priorityLabel'] as String?,
  priorityColor: json['priorityColor'] as String?,
  driver: json['driver'] == null
      ? null
      : DispatcherIssueDriverDto.fromJson(
          json['driver'] as Map<String, dynamic>,
        ),
  description: json['description'] as String?,
  evidencePhotos: (json['evidencePhotos'] as List<dynamic>?)
      ?.map(
        (e) => DispatcherIssueAttachmentDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map(
        (e) => DispatcherIssueAttachmentDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  tripInfo: json['tripInfo'] == null
      ? null
      : DispatcherIssueTripDto.fromJson(
          json['tripInfo'] as Map<String, dynamic>,
        ),
  resolution: json['resolution'] == null
      ? null
      : DispatcherIssueResolutionDto.fromJson(
          json['resolution'] as Map<String, dynamic>,
        ),
);

DispatcherIssueDriverDto _$DispatcherIssueDriverDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherIssueDriverDto(
  id: json['id'] as String?,
  driverId: json['driverId'] as String?,
  name: json['name'] as String?,
  driverName: json['driverName'] as String?,
  code: json['code'] as String?,
  driverCode: json['driverCode'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  driverAvatar: json['driverAvatar'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  phone: json['phone'] as String?,
  isOnline: json['isOnline'] as bool?,
  status: json['status'] as String?,
  statusLabel: json['statusLabel'] as String?,
  subStatus: json['subStatus'] as String?,
  driverSubStatus: json['driverSubStatus'] as String?,
  vehicleInfo: json['vehicleInfo'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
);

DispatcherIssueAttachmentDto _$DispatcherIssueAttachmentDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherIssueAttachmentDto(
  id: json['id'] as String?,
  url: json['url'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  uploadedAt: json['uploadedAt'] as String?,
  uploadedAtUtc: json['uploadedAtUtc'] as String?,
  orderNumber: (json['orderNumber'] as num?)?.toInt(),
);

DispatcherIssueTripDto _$DispatcherIssueTripDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherIssueTripDto(
  clientName: json['clientName'] as String?,
  mealsCount: (json['mealsCount'] as num?)?.toInt(),
  expectedDeliveryTime: json['expectedDeliveryTime'] as String?,
  pickupLocation: json['pickupLocation'] as String?,
  dropoffLocation: json['dropoffLocation'] as String?,
  orderId: json['orderId'] as String?,
);

DispatcherIssueResolutionDto _$DispatcherIssueResolutionDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherIssueResolutionDto(
  resolutionNotes: json['resolutionNotes'] as String?,
  notes: json['notes'] as String?,
  resolvedBy: json['resolvedBy'] as String?,
  resolvedAt: json['resolvedAt'] as String?,
  resolvedAtUtc: json['resolvedAtUtc'] as String?,
  resolvedAtText: json['resolvedAtText'] as String?,
  resolvedAction: json['resolvedAction'] as String?,
  resolvedActionLabel: json['resolvedActionLabel'] as String?,
);

import '../../domain/entities/dispatcher_issue_attachment_entity.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';
import '../../domain/entities/dispatcher_issue_driver_entity.dart';
import '../../domain/entities/dispatcher_issue_resolution_entity.dart';
import '../../domain/entities/dispatcher_issue_status.dart';
import '../../domain/entities/dispatcher_issue_trip_entity.dart';
import '../../domain/entities/resolve_issue_result_entity.dart';
import '../models/response/dispatcher_issue_details_response_dto.dart';
import '../models/response/resolve_issue_response_dto.dart';

extension DispatcherIssueDetailsResponseDtoMapper
    on DispatcherIssueDetailsResponseDto {
  DispatcherIssueDetailEntity toEntity() {
    final rawDate = createdAtUtc ?? createdAt;
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;

    final resolvedPriority = priority ?? '';
    final resolvedPriorityText = priorityText ?? priorityLabel ?? resolvedPriority;

    return DispatcherIssueDetailEntity(
      issueId: issueId ?? id ?? '',
      title: title ?? '',
      category: category ?? '',
      categoryLabel: categoryLabel ?? '',
      categoryColorHex: categoryColor ?? '#EF4444',
      createdAtUtc: parsedDate,
      reportedTimeText: reportedTimeText ?? timeAgo ?? '',
      status: DispatcherIssueStatusX.fromApi(status),
      statusLabel: statusLabel ?? '',
      boxCode: boxCode ?? taskNumber ?? '',
      area: area ?? '',
      affectedBoxesCount: affectedBoxesCount ?? 0,
      affectedBoxesText: affectedBoxesText ?? '',
      priority: resolvedPriority,
      priorityText: resolvedPriorityText,
      priorityColorHex: priorityColor ?? '#EF4444',
      driver: driver?.toEntity(),
      description: description ?? '',
      evidencePhotos: (evidencePhotos ?? attachments ?? const [])
          .map((photo) => photo.toEntity())
          .toList(),
      tripInfo: tripInfo?.toEntity() ??
          const DispatcherIssueTripEntity(
            clientName: '',
            mealsCount: 0,
            expectedDeliveryTime: '',
            pickupLocation: '',
            dropoffLocation: '',
          ),
      resolution: resolution?.toEntity(),
    );
  }
}

extension DispatcherIssueDriverDtoMapper on DispatcherIssueDriverDto {
  DispatcherIssueDriverEntity toEntity() {
    return DispatcherIssueDriverEntity(
      id: id ?? driverId ?? '',
      name: name ?? driverName ?? '',
      code: code ?? driverCode ?? '',
      avatarUrl: avatarUrl ?? driverAvatar,
      phoneNumber: phoneNumber ?? phone,
      isOnline: isOnline ?? true,
      status: status ?? '',
      statusLabel: statusLabel ?? '',
      subStatus: subStatus ?? driverSubStatus ?? '',
      vehicleInfo: vehicleInfo,
      rating: rating,
    );
  }
}

extension DispatcherIssueAttachmentDtoMapper on DispatcherIssueAttachmentDto {
  DispatcherIssueAttachmentEntity toEntity() {
    final rawDate = uploadedAtUtc ?? uploadedAt;
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;

    return DispatcherIssueAttachmentEntity(
      id: id ?? '',
      url: url ?? '',
      thumbnailUrl: thumbnailUrl ?? url,
      uploadedAtUtc: parsedDate,
      orderNumber: orderNumber ?? 1,
    );
  }
}

extension DispatcherIssueTripDtoMapper on DispatcherIssueTripDto {
  DispatcherIssueTripEntity toEntity() {
    return DispatcherIssueTripEntity(
      clientName: clientName ?? '',
      mealsCount: mealsCount ?? 0,
      expectedDeliveryTime: expectedDeliveryTime ?? '',
      pickupLocation: pickupLocation ?? '',
      dropoffLocation: dropoffLocation ?? '',
      orderId: orderId,
    );
  }
}

extension DispatcherIssueResolutionDtoMapper on DispatcherIssueResolutionDto {
  DispatcherIssueResolutionEntity toEntity() {
    final rawDate = resolvedAtUtc ?? resolvedAt;
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;

    return DispatcherIssueResolutionEntity(
      resolutionNotes: resolutionNotes ?? notes ?? '',
      resolvedBy: resolvedBy,
      resolvedAtUtc: parsedDate,
      resolvedAtText: resolvedAtText,
      resolvedAction: resolvedAction,
      resolvedActionLabel: resolvedActionLabel,
    );
  }
}

extension ResolveIssueResponseDtoMapper on ResolveIssueResponseDto {
  ResolveIssueResultEntity toEntity() {
    return ResolveIssueResultEntity(
      issueId: issueId ?? id ?? '',
      status: DispatcherIssueStatusX.fromApi(status),
      statusLabel: statusLabel ?? '',
      resolution: resolution?.toEntity(),
      message: message,
    );
  }
}

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

    final resolvedPriority =
        metadata?.priority ?? priority ?? '';
    final resolvedPriorityText = metadata?.priorityText ??
        metadata?.priorityLabel ??
        priorityText ??
        priorityLabel ??
        resolvedPriority;
    final resolvedPriorityColor =
        metadata?.priorityColor ?? priorityColor ?? '#EF4444';
    final resolvedBoxCode = metadata?.boxCode ??
        metadata?.taskNumber ??
        boxCode ??
        taskNumber ??
        '';
    final resolvedArea = metadata?.area ?? area ?? '';
    final resolvedAffectedBoxesCount =
        metadata?.affectedBoxesCount ?? affectedBoxesCount ?? 0;
    final resolvedAffectedBoxesText =
        metadata?.affectedBoxesText ?? affectedBoxesText ?? '';

    final rawPhotos = evidencePhotos ?? attachments ?? const [];
    final mappedPhotos = <DispatcherIssueAttachmentEntity>[];
    for (var i = 0; i < rawPhotos.length; i++) {
      mappedPhotos.add(rawPhotos[i].toEntity(fallbackOrderNumber: i + 1));
    }

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
      boxCode: resolvedBoxCode,
      area: resolvedArea,
      affectedBoxesCount: resolvedAffectedBoxesCount,
      affectedBoxesText: resolvedAffectedBoxesText,
      priority: resolvedPriority,
      priorityText: resolvedPriorityText,
      priorityColorHex: resolvedPriorityColor,
      driver: driver?.toEntity(),
      description: description ?? '',
      evidencePhotos: mappedPhotos,
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
    final resolvedStatus = status ?? '';
    final resolvedStatusLower = resolvedStatus.trim().toLowerCase();
    final computedIsOnline = isOnline ??
        (resolvedStatusLower == 'available' ||
            resolvedStatusLower == 'online' ||
            resolvedStatusLower == 'متصل');

    return DispatcherIssueDriverEntity(
      id: id ?? driverId ?? '',
      name: fullName ?? name ?? driverName ?? '',
      code: code ?? driverCode ?? '',
      avatarUrl: avatarUrl ?? driverAvatar,
      phoneNumber: phoneNumber ?? phone,
      isOnline: computedIsOnline,
      status: resolvedStatus,
      statusLabel: statusText ?? statusLabel ?? resolvedStatus,
      statusColorHex: statusColor,
      subStatus: subStatus ?? driverSubStatus ?? '',
      vehicleInfo: vehicleInfo,
      rating: rating,
    );
  }
}

extension DispatcherIssueAttachmentDtoMapper on DispatcherIssueAttachmentDto {
  DispatcherIssueAttachmentEntity toEntity({int? fallbackOrderNumber}) {
    final rawDate = uploadedAtUtc ?? uploadedAt;
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;

    return DispatcherIssueAttachmentEntity(
      id: id ?? '',
      url: url ?? '',
      thumbnailUrl: thumbnailUrl ?? url,
      uploadedAtUtc: parsedDate,
      orderNumber: orderNumber ?? fallbackOrderNumber ?? 1,
    );
  }
}

extension DispatcherIssueTripDtoMapper on DispatcherIssueTripDto {
  DispatcherIssueTripEntity toEntity() {
    return DispatcherIssueTripEntity(
      clientName: customerName ?? clientName ?? '',
      mealsCount: mealsCount ?? 0,
      expectedDeliveryTime:
          expectedDeliveryTimeText ?? expectedDeliveryTime ?? '',
      pickupLocation: pickupLocation ?? '',
      dropoffLocation: deliveryAddress ?? dropoffLocation ?? '',
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

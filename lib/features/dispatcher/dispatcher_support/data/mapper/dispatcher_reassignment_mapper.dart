import '../../domain/entities/dispatcher_issue_status.dart';
import '../../domain/entities/dispatcher_support_response_entity.dart';
import '../../domain/entities/reassign_driver_candidate_entity.dart';
import '../../domain/entities/reassign_driver_candidates_entity.dart';
import '../../domain/entities/reassign_driver_request_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../models/request/reassign_driver_request_dto.dart';
import '../models/response/reassign_driver_candidates_response_dto.dart';
import '../models/response/reassignment_response_dto.dart';
import 'dispatcher_issue_details_mapper.dart';
import 'dispatcher_support_mapper.dart';

extension ReassignDriverCandidatesResponseDtoMapper
    on ReassignDriverCandidatesResponseDto {
  ReassignDriverCandidatesEntity toEntity() {
    return ReassignDriverCandidatesEntity(
      summary: summary?.toEntity() ??
          const ReassignDriverIssueSummaryEntity(
            issueId: '',
            title: '',
          ),
      currentDriver: currentDriver?.toEntity(),
      candidates:
          candidates?.map((candidate) => candidate.toEntity()).toList() ??
              const [],
      pagination:
          pagination?.toEntity() ?? const DispatcherSupportPaginationEntity(),
    );
  }
}

extension ReassignDriverIssueSummaryDtoMapper on ReassignDriverIssueSummaryDto {
  ReassignDriverIssueSummaryEntity toEntity() {
    return ReassignDriverIssueSummaryEntity(
      issueId: issueId ?? id ?? '',
      title: title ?? '',
      category: category ?? '',
      categoryLabel: categoryLabel ?? '',
      categoryColorHex: categoryColor ?? '#EF4444',
      reportedTimeText: reportedTimeText ?? '',
      minutesAgo: minutesAgo ?? 0,
      priority: priority ?? '',
      priorityText: priorityText ?? priority ?? '',
      priorityColorHex: priorityColor ?? '#EF4444',
      taskNumber: taskNumber ?? boxCode ?? '',
      area: area ?? '',
      affectedBoxesCount: affectedBoxesCount ?? 0,
      affectedBoxesText: affectedBoxesText ?? '',
      description: description ?? '',
    );
  }
}

extension ReassignDriverCandidateDtoMapper on ReassignDriverCandidateDto {
  ReassignDriverCandidateEntity toEntity() {
    final rawDate = lastLocationUpdateUtc ?? lastLocationUpdate;
    final parsedDate = rawDate != null ? DateTime.tryParse(rawDate) : null;

    final resolvedRank = recommendationRank ?? rank ?? 1;
    final resolvedOrdersCount = activeOrdersCount ?? ordersCount ?? 0;
    final resolvedDistance = distanceKm ?? 0.0;
    final resolvedStatus = status ?? (isAvailable == false ? 'BUSY' : 'AVAILABLE');

    return ReassignDriverCandidateEntity(
      id: id ?? driverId ?? '',
      name: name ?? '',
      code: code ?? '',
      avatarUrl: avatarUrl,
      avatarAsset: null,
      isAvailable: isAvailable ?? (resolvedStatus.toUpperCase() == 'AVAILABLE'),
      status: resolvedStatus,
      statusText: statusText ?? (resolvedStatus.toUpperCase() == 'AVAILABLE' ? 'متاح' : 'مشغول'),
      statusColorHex: statusColorHex ??
          (resolvedStatus.toUpperCase() == 'AVAILABLE' ? '#10B981' : '#F59E0B'),
      rating: rating ?? 0.0,
      activeOrdersCount: resolvedOrdersCount,
      ordersCount: resolvedOrdersCount,
      area: area ?? '',
      isSameArea: isSameArea ?? false,
      distanceKm: resolvedDistance,
      distanceText: distanceText ?? (resolvedDistance > 0 ? '$resolvedDistance كم' : ''),
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? 0,
      estimatedArrivalText: estimatedArrivalText ?? '',
      vehicleInfo: vehicleInfo ?? '',
      lastLocationUpdateUtc: parsedDate,
      lastLocationUpdateText: lastLocationUpdateText ?? '',
      recommendationRank: resolvedRank,
    );
  }
}

extension ReassignmentResponseDtoMapper on ReassignmentResponseDto {
  ReassignmentResultEntity toEntity() {
    return ReassignmentResultEntity(
      issueId: issueId ?? id ?? '',
      status: DispatcherIssueStatusX.fromApi(status),
      statusLabel: statusLabel ?? '',
      reassignedDriver: reassignedDriver?.toEntity(),
      message: message,
      resolution: resolution?.toEntity(),
    );
  }
}

extension ReassignDriverRequestEntityMapper on ReassignDriverRequestEntity {
  ReassignDriverRequestDto toDto() {
    return ReassignDriverRequestDto(
      replacementDriverId: replacementDriverId,
      notes: notes,
    );
  }
}

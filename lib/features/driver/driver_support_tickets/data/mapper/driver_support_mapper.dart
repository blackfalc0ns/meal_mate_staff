import '../../domain/entities/driver_support_add_photos_result_entity.dart';
import '../../domain/entities/driver_support_issues_page_entity.dart';
import '../../domain/entities/driver_support_ticket_details_entity.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import '../../domain/entities/driver_support_ticket_status.dart';
import '../../domain/entities/driver_support_ticket_timeline_step.dart';
import '../models/response/driver_support_add_photos_response_dto.dart';
import '../models/response/driver_support_issue_details_response_dto.dart';
import '../models/response/driver_support_issue_summary_dto.dart';
import '../models/response/driver_support_issues_response_dto.dart';
import '../models/response/driver_support_timeline_step_dto.dart';

class DriverSupportMapper {
  const DriverSupportMapper._();

  static DriverSupportTicketStatus mapStatus(String? raw) {
    if (raw == null) return DriverSupportTicketStatus.underReview;
    return switch (raw.toLowerCase()) {
      'resolved' => DriverSupportTicketStatus.resolved,
      'awaitingreply' || 'awaitingresponse' =>
        DriverSupportTicketStatus.awaitingResponse,
      'underreview' => DriverSupportTicketStatus.underReview,
      _ => DriverSupportTicketStatus.underReview,
    };
  }

  static DriverTicketStepState mapTimelineState(String? raw) {
    if (raw == null) return DriverTicketStepState.pending;
    return switch (raw.toLowerCase()) {
      'completed' => DriverTicketStepState.completed,
      'current' => DriverTicketStepState.inProgress,
      'unrecorded' => DriverTicketStepState.pending,
      _ => DriverTicketStepState.pending,
    };
  }

  static DateTime? parseUtc(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      final parsed = DateTime.parse(dateStr);
      return parsed.isUtc ? parsed : parsed.toUtc();
    } catch (_) {
      return null;
    }
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  static DriverSupportTicketEntity mapSummaryToEntity(
    DriverSupportIssueSummaryDto dto,
  ) {
    final submittedUtc = parseUtc(dto.submittedAtUtc);
    final formattedDate = formatDate(submittedUtc);
    final boxNum = dto.orderCode ?? (dto.categoryLabel ?? dto.title ?? '');
    final title = dto.title ?? dto.categoryLabel ?? '';

    return DriverSupportTicketEntity(
      id: dto.issueId ?? '',
      boxNumber: boxNum,
      title: title,
      location: '',
      updatedAt: formattedDate,
      status: mapStatus(dto.status),
      createdAt: formattedDate,
      category: dto.category,
      categoryLabel: dto.categoryLabel,
      statusLabel: dto.statusLabel,
      rawStatus: dto.status,
      submittedAtUtc: submittedUtc,
      orderCode: dto.orderCode,
    );
  }

  static DriverSupportIssuesPageEntity mapIssuesPageToEntity(
    DriverSupportIssuesResponseDto dto,
  ) {
    final issuesList = (dto.issues ?? [])
        .where((i) => i.issueId != null && i.issueId!.trim().isNotEmpty)
        .map(mapSummaryToEntity)
        .toList();

    return DriverSupportIssuesPageEntity(
      allCount: dto.allCount ?? 0,
      underReviewCount: dto.underReviewCount ?? 0,
      awaitingReplyCount: dto.awaitingReplyCount ?? 0,
      resolvedCount: dto.resolvedCount ?? 0,
      totalCount: dto.totalCount ?? 0,
      pageNumber: dto.pageNumber ?? 1,
      pageSize: dto.pageSize ?? 20,
      issues: issuesList,
    );
  }

  static DriverSupportTimelineStepDto? findTimelineStage(
    List<DriverSupportTimelineStepDto>? steps,
    String stage,
  ) {
    if (steps == null) return null;
    for (final s in steps) {
      if (s.stage?.toLowerCase() == stage.toLowerCase()) return s;
    }
    return null;
  }

  static DriverSupportTicketTimelineStep mapTimelineStep(
    DriverSupportTimelineStepDto dto,
  ) {
    final stepState = mapTimelineState(dto.state);
    final occurredUtc = parseUtc(dto.occurredAtUtc);

    return DriverSupportTicketTimelineStep(
      title: dto.label ?? dto.stage ?? '',
      state: stepState,
      timestamp: occurredUtc != null ? formatDate(occurredUtc) : null,
      isHighlighted: stepState == DriverTicketStepState.inProgress,
    );
  }

  static DriverSupportTicketDetailsEntity mapDetailsToEntity(
    DriverSupportIssueDetailsResponseDto dto,
  ) {
    final timelineSteps = (dto.timeline ?? []).map(mapTimelineStep).toList();

    return DriverSupportTicketDetailsEntity(
      issueId: dto.issueId ?? '',
      category: dto.category ?? '',
      categoryLabel: dto.categoryLabel ?? '',
      title: dto.title ?? dto.categoryLabel ?? '',
      description: dto.description,
      status: mapStatus(dto.status),
      rawStatus: dto.rawStatus ?? dto.status ?? '',
      statusLabel: dto.statusLabel ?? '',
      submittedAtUtc: parseUtc(dto.submittedAtUtc),
      updatedAtUtc: parseUtc(dto.updatedAtUtc),
      orderCode: dto.orderCode,
      address: dto.address,
      area: dto.area,
      orderCreatedAtUtc: parseUtc(dto.orderCreatedAtUtc),
      timeline: timelineSteps,
      evidenceUrls: dto.evidenceUrls ?? const [],
      resolutionNotes: dto.resolutionNotes,
      resolvedAtUtc: parseUtc(dto.resolvedAtUtc),
      canContactSupport: dto.canContactSupport ?? false,
      contactChannel: dto.contactChannel,
    );
  }

  static DriverSupportAddPhotosResultEntity mapAddPhotosResultToEntity(
    DriverSupportAddPhotosResponseDto dto,
  ) {
    return DriverSupportAddPhotosResultEntity(
      issueId: dto.issueId ?? '',
      status: mapStatus(dto.status),
      statusLabel: dto.status ?? '',
      evidenceUrls: dto.evidenceUrls ?? const [],
    );
  }
}

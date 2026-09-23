import '../../domain/entities/box_issue_type.dart';
import '../../domain/entities/box_tracking_driver_entity.dart';
import '../../domain/entities/box_tracking_entity.dart';
import '../../domain/entities/box_tracking_status.dart';
import '../../domain/entities/box_tracking_step_entity.dart';
import '../../domain/entities/box_tracking_step_icon_kind.dart';
import '../../domain/entities/box_tracking_step_state.dart';
import '../../domain/entities/report_box_issue_request_entity.dart';
import '../../domain/entities/report_box_issue_result_entity.dart';
import '../models/request/report_box_issue_request_dto.dart';
import '../models/response/box_tracking_response_dto.dart';
import '../models/response/report_box_issue_response_dto.dart';

extension BoxTrackingResponseDtoMapper on BoxTrackingResponseDto {
  BoxTrackingEntity toEntity() {
    final boxInfo = box;
    final driverInfo = driver;
    final detailsInfo = details;

    final stepsList =
        (timeline ?? const [])
            .whereType<BoxTimelineStepDto>()
            .map(
              (stepDto) => BoxTrackingStepEntity(
                step: stepDto.step ?? 0,
                title: stepDto.title ?? '',
                description: stepDto.description,
                time: stepDto.time,
                state: BoxTrackingStepStateX.fromApi(stepDto.state),
                iconKind: BoxTrackingStepIconKindX.fromApi(stepDto.icon),
              ),
            )
            .toList()
          ..sort((a, b) => a.step.compareTo(b.step));

    BoxTrackingDriverEntity? driverEntity;
    if (driverInfo != null &&
        (driverInfo.driverId != null || driverInfo.fullName != null)) {
      driverEntity = BoxTrackingDriverEntity(
        driverId: driverInfo.driverId ?? '',
        driverCode: driverInfo.driverCode ?? '',
        fullName: driverInfo.fullName ?? '',
        phoneNumber: driverInfo.phoneNumber ?? '',
        avatarUrl: driverInfo.avatarUrl,
      );
    }

    return BoxTrackingEntity(
      boxId: boxInfo?.boxId ?? '',
      boxCode: boxInfo?.boxCode ?? '',
      status: BoxTrackingStatusX.fromApi(boxInfo?.status),
      statusText: boxInfo?.statusText ?? '',
      statusColor: boxInfo?.statusColor ?? '',
      customerName: boxInfo?.customerName ?? '',
      scheduledTimeText: boxInfo?.scheduledTimeText ?? '',
      deliveryAddress: boxInfo?.deliveryAddress ?? '',
      driver: driverEntity,
      programType: detailsInfo?.programType ?? '',
      orderDateText: detailsInfo?.orderDateText ?? '',
      customerNotes: detailsInfo?.customerNotes ?? '',
      mealsSummary: detailsInfo?.mealsSummary ?? '',
      steps: List.unmodifiable(stepsList),
    );
  }
}

extension ReportBoxIssueRequestEntityMapper on ReportBoxIssueRequestEntity {
  ReportBoxIssueRequestDto toDto() {
    return ReportBoxIssueRequestDto(
      issueType: issueType.toApi(),
      description: description.trim(),
      severity: severity,
    );
  }
}

extension ReportBoxIssueResponseDtoMapper on ReportBoxIssueResponseDto {
  ReportBoxIssueResultEntity toEntity() {
    return ReportBoxIssueResultEntity(
      issueId: issueId ?? '',
      boxId: boxId ?? '',
      reportedAtUtc: reportedAtUtc != null
          ? DateTime.tryParse(reportedAtUtc!)
          : null,
      message: message ?? '',
    );
  }
}

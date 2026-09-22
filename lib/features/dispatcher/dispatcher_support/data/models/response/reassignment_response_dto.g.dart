// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reassignment_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReassignmentResponseDto _$ReassignmentResponseDtoFromJson(
  Map<String, dynamic> json,
) => ReassignmentResponseDto(
  issueId: json['issueId'] as String?,
  id: json['id'] as String?,
  status: json['status'] as String?,
  statusLabel: json['statusLabel'] as String?,
  reassignedDriver: json['reassignedDriver'] == null
      ? null
      : DispatcherIssueDriverDto.fromJson(
          json['reassignedDriver'] as Map<String, dynamic>,
        ),
  message: json['message'] as String?,
  resolution: json['resolution'] == null
      ? null
      : DispatcherIssueResolutionDto.fromJson(
          json['resolution'] as Map<String, dynamic>,
        ),
);

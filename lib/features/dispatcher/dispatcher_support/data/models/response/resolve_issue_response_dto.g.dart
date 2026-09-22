// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_issue_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveIssueResponseDto _$ResolveIssueResponseDtoFromJson(
  Map<String, dynamic> json,
) => ResolveIssueResponseDto(
  issueId: json['issueId'] as String?,
  id: json['id'] as String?,
  status: json['status'] as String?,
  statusLabel: json['statusLabel'] as String?,
  resolution: json['resolution'] == null
      ? null
      : DispatcherIssueResolutionDto.fromJson(
          json['resolution'] as Map<String, dynamic>,
        ),
  message: json['message'] as String?,
);

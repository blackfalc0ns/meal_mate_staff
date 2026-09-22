import 'package:json_annotation/json_annotation.dart';

part 'resolve_issue_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class ResolveIssueRequestDto {
  const ResolveIssueRequestDto({
    required this.resolutionNotes,
  });

  factory ResolveIssueRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ResolveIssueRequestDtoFromJson(json);

  final String resolutionNotes;

  Map<String, dynamic> toJson() => _$ResolveIssueRequestDtoToJson(this);
}

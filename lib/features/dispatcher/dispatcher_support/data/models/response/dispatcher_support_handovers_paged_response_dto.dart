import 'package:json_annotation/json_annotation.dart';

import 'package:meal_mate_delivery/features/driver/support_handovers/data/models/response/support_handover_response_dto.dart';

part 'dispatcher_support_handovers_paged_response_dto.g.dart';

@JsonSerializable()
class DispatcherSupportHandoversPagedResponseDto {
  const DispatcherSupportHandoversPagedResponseDto({
    this.items,
    this.totalCount,
    this.pageNumber,
    this.pageSize,
  });

  factory DispatcherSupportHandoversPagedResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherSupportHandoversPagedResponseDtoFromJson(json);

  final List<SupportHandoverResponseDto>? items;
  final int? totalCount;
  final int? pageNumber;
  final int? pageSize;

  Map<String, dynamic> toJson() =>
      _$DispatcherSupportHandoversPagedResponseDtoToJson(this);
}

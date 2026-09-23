import 'package:json_annotation/json_annotation.dart';

part 'operations_log_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class OperationsLogResponseDto {
  const OperationsLogResponseDto({
    this.counters,
    this.operations,
    this.pagination,
  });

  factory OperationsLogResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OperationsLogResponseDtoFromJson(json);

  final OperationsCountersResponseDto? counters;
  final List<OperationResponseDto>? operations;
  final OperationsPaginationResponseDto? pagination;
}

@JsonSerializable(createToJson: false)
class OperationsCountersResponseDto {
  const OperationsCountersResponseDto({
    this.allCount,
    this.completedCount,
    this.cancelledCount,
    this.failedCount,
    this.reassignedCount,
  });

  factory OperationsCountersResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OperationsCountersResponseDtoFromJson(json);

  final int? allCount;
  final int? completedCount;
  final int? cancelledCount;
  final int? failedCount;
  final int? reassignedCount;
}

@JsonSerializable(createToJson: false)
class OperationResponseDto {
  const OperationResponseDto({
    this.id,
    this.boxId,
    this.boxCode,
    this.type,
    this.statusText,
    this.statusColor,
    this.statusIcon,
    this.customer,
    this.timeText,
    this.occurredAtUtc,
    this.driver,
    this.originalDriver,
    this.replacementDriver,
    this.cancelledBy,
    this.cancelledByText,
  });

  factory OperationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OperationResponseDtoFromJson(json);

  final String? id;
  final String? boxId;
  final String? boxCode;
  final String? type;
  final String? statusText;
  final String? statusColor;
  final String? statusIcon;
  final OperationCustomerResponseDto? customer;
  final String? timeText;
  final String? occurredAtUtc;
  final OperationDriverResponseDto? driver;
  final OperationDriverResponseDto? originalDriver;
  final OperationDriverResponseDto? replacementDriver;
  final String? cancelledBy;
  final String? cancelledByText;
}

@JsonSerializable(createToJson: false)
class OperationDriverResponseDto {
  const OperationDriverResponseDto({
    this.id,
    this.name,
    this.avatarUrl,
    this.indicatorColor,
  });

  factory OperationDriverResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OperationDriverResponseDtoFromJson(json);

  final String? id;
  final String? name;
  final String? avatarUrl;
  final String? indicatorColor;
}

@JsonSerializable(createToJson: false)
class OperationCustomerResponseDto {
  const OperationCustomerResponseDto({
    this.id,
    this.name,
    this.area,
    this.addressText,
    this.labelText,
  });

  factory OperationCustomerResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OperationCustomerResponseDtoFromJson(json);

  final String? id;
  final String? name;
  final String? area;
  final String? addressText;
  final String? labelText;
}

@JsonSerializable(createToJson: false)
class OperationsPaginationResponseDto {
  const OperationsPaginationResponseDto({
    this.pageNumber,
    this.pageSize,
    this.totalPages,
    this.totalItems,
    this.hasPreviousPage,
    this.hasNextPage,
  });

  factory OperationsPaginationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OperationsPaginationResponseDtoFromJson(json);

  final int? pageNumber;
  final int? pageSize;
  final int? totalPages;
  final int? totalItems;
  final bool? hasPreviousPage;
  final bool? hasNextPage;
}

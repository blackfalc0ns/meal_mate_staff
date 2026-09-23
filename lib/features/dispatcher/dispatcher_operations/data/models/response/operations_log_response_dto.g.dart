// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operations_log_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationsLogResponseDto _$OperationsLogResponseDtoFromJson(
  Map<String, dynamic> json,
) => OperationsLogResponseDto(
  counters: json['counters'] == null
      ? null
      : OperationsCountersResponseDto.fromJson(
          json['counters'] as Map<String, dynamic>,
        ),
  operations: (json['operations'] as List<dynamic>?)
      ?.map((e) => OperationResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : OperationsPaginationResponseDto.fromJson(
          json['pagination'] as Map<String, dynamic>,
        ),
);

OperationsCountersResponseDto _$OperationsCountersResponseDtoFromJson(
  Map<String, dynamic> json,
) => OperationsCountersResponseDto(
  allCount: (json['allCount'] as num?)?.toInt(),
  completedCount: (json['completedCount'] as num?)?.toInt(),
  cancelledCount: (json['cancelledCount'] as num?)?.toInt(),
  failedCount: (json['failedCount'] as num?)?.toInt(),
  reassignedCount: (json['reassignedCount'] as num?)?.toInt(),
);

OperationResponseDto _$OperationResponseDtoFromJson(
  Map<String, dynamic> json,
) => OperationResponseDto(
  id: json['id'] as String?,
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  type: json['type'] as String?,
  statusText: json['statusText'] as String?,
  statusColor: json['statusColor'] as String?,
  statusIcon: json['statusIcon'] as String?,
  customer: json['customer'] == null
      ? null
      : OperationCustomerResponseDto.fromJson(
          json['customer'] as Map<String, dynamic>,
        ),
  timeText: json['timeText'] as String?,
  occurredAtUtc: json['occurredAtUtc'] as String?,
  driver: json['driver'] == null
      ? null
      : OperationDriverResponseDto.fromJson(
          json['driver'] as Map<String, dynamic>,
        ),
  originalDriver: json['originalDriver'] == null
      ? null
      : OperationDriverResponseDto.fromJson(
          json['originalDriver'] as Map<String, dynamic>,
        ),
  replacementDriver: json['replacementDriver'] == null
      ? null
      : OperationDriverResponseDto.fromJson(
          json['replacementDriver'] as Map<String, dynamic>,
        ),
  cancelledBy: json['cancelledBy'] as String?,
  cancelledByText: json['cancelledByText'] as String?,
);

OperationDriverResponseDto _$OperationDriverResponseDtoFromJson(
  Map<String, dynamic> json,
) => OperationDriverResponseDto(
  id: json['id'] as String?,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  indicatorColor: json['indicatorColor'] as String?,
);

OperationCustomerResponseDto _$OperationCustomerResponseDtoFromJson(
  Map<String, dynamic> json,
) => OperationCustomerResponseDto(
  id: json['id'] as String?,
  name: json['name'] as String?,
  area: json['area'] as String?,
  addressText: json['addressText'] as String?,
  labelText: json['labelText'] as String?,
);

OperationsPaginationResponseDto _$OperationsPaginationResponseDtoFromJson(
  Map<String, dynamic> json,
) => OperationsPaginationResponseDto(
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  totalItems: (json['totalItems'] as num?)?.toInt(),
  hasPreviousPage: json['hasPreviousPage'] as bool?,
  hasNextPage: json['hasNextPage'] as bool?,
);

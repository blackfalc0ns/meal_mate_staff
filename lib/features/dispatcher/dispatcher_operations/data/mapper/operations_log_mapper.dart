import '../../domain/entities/operation_item_entity.dart';
import '../../domain/entities/operation_status.dart';
import '../../domain/entities/operations_counters_entity.dart';
import '../../domain/entities/operations_customer_entity.dart';
import '../../domain/entities/operations_driver_entity.dart';
import '../../domain/entities/operations_indicator_color.dart';
import '../../domain/entities/operations_page_entity.dart';
import '../../domain/entities/operations_pagination_entity.dart';
import '../models/response/operations_log_response_dto.dart';

extension OperationsLogResponseDtoMapper on OperationsLogResponseDto {
  OperationsPageEntity toEntity() => OperationsPageEntity(
    counters: counters?.toEntity() ?? const OperationsCountersEntity(),
    operations:
        operations?.map((item) => item.toEntity()).toList(growable: false) ??
        const <OperationItemEntity>[],
    pagination: pagination?.toEntity() ?? const OperationsPaginationEntity(),
  );
}

extension OperationsCountersResponseDtoMapper on OperationsCountersResponseDto {
  OperationsCountersEntity toEntity() => OperationsCountersEntity(
    allCount: (allCount != null && allCount! >= 0) ? allCount! : 0,
    completedCount: (completedCount != null && completedCount! >= 0)
        ? completedCount!
        : 0,
    cancelledCount: (cancelledCount != null && cancelledCount! >= 0)
        ? cancelledCount!
        : 0,
    failedCount: (failedCount != null && failedCount! >= 0) ? failedCount! : 0,
    reassignedCount: (reassignedCount != null && reassignedCount! >= 0)
        ? reassignedCount!
        : 0,
  );
}

extension OperationsPaginationResponseDtoMapper
    on OperationsPaginationResponseDto {
  OperationsPaginationEntity toEntity() => OperationsPaginationEntity(
    pageNumber: (pageNumber != null && pageNumber! > 0) ? pageNumber! : 1,
    pageSize: (pageSize != null && pageSize! > 0) ? pageSize! : 10,
    totalPages: (totalPages != null && totalPages! >= 0) ? totalPages! : 0,
    totalItems: (totalItems != null && totalItems! >= 0) ? totalItems! : 0,
    hasPreviousPage: hasPreviousPage ?? false,
    hasNextPage: hasNextPage ?? false,
  );
}

extension OperationResponseDtoMapper on OperationResponseDto {
  OperationItemEntity toEntity() {
    DateTime? parsedDate;
    if (occurredAtUtc != null && occurredAtUtc!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(occurredAtUtc!.trim());
      if (parsed != null) {
        parsedDate = parsed.toUtc();
      }
    }

    return OperationItemEntity(
      id: id ?? '',
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      status: OperationStatusX.fromApi(type),
      customer:
          customer?.toEntity() ??
          const OperationsCustomerEntity(
            id: '',
            name: '',
            area: '',
            addressText: '',
          ),
      timeText: timeText ?? '',
      occurredAtUtc: parsedDate,
      driver: driver?.toEntity(),
      originalDriver: originalDriver?.toEntity(),
      replacementDriver: replacementDriver?.toEntity(),
      cancelledBy: cancelledBy,
      cancelledByText: cancelledByText,
    );
  }
}

extension OperationDriverResponseDtoMapper on OperationDriverResponseDto {
  OperationsDriverEntity toEntity() {
    final avatar = (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
        ? avatarUrl!.trim()
        : null;

    return OperationsDriverEntity(
      id: id ?? '',
      name: name ?? '',
      avatarUrl: avatar,
      indicatorColor: OperationsIndicatorColorX.fromApi(indicatorColor),
    );
  }
}

extension OperationCustomerResponseDtoMapper on OperationCustomerResponseDto {
  OperationsCustomerEntity toEntity() {
    final trimmedArea = area?.trim() ?? '';
    final trimmedAddress = addressText?.trim() ?? '';
    final resolvedArea = trimmedArea.isNotEmpty ? trimmedArea : trimmedAddress;

    return OperationsCustomerEntity(
      id: id ?? '',
      name: name ?? '',
      area: resolvedArea,
      addressText: trimmedAddress,
    );
  }
}

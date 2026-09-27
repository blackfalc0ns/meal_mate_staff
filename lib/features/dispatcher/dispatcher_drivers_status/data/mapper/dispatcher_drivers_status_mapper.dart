import '../../../../../core/network/network_constants.dart';
import '../../domain/entities/dispatcher_driver_status_item_entity.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_pagination_entity.dart';
import '../../domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import '../../domain/entities/dispatcher_drivers_status_summary_entity.dart';
import '../../domain/entities/update_driver_availability_result_entity.dart';
import '../models/response/dispatcher_drivers_status_response_dto.dart';
import '../models/response/update_driver_availability_response_dto.dart';

class DispatcherDriversStatusMapper {
  const DispatcherDriversStatusMapper._();

  static String? resolveAvatarUrl(String? key, {String? baseUrl}) {
    if (key == null) return null;
    final trimmed = key.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = baseUrl ?? NetworkConstants.baseUrl;
    final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return Uri.parse(base).resolve('/$normalized').toString();
  }

  static int _clampNonNegative(int? value) {
    if (value == null || value < 0) return 0;
    return value;
  }

  static DispatcherDriversStatusSummaryEntity toEntity(
    DispatcherDriversStatusResponseDto dto, {
    String? baseUrl,
  }) {
    final countsDto = dto.counts;
    final counts = DispatcherDriversStatusKpisEntity(
      total: _clampNonNegative(countsDto?.total),
      available: _clampNonNegative(countsDto?.available),
      inDelivery: _clampNonNegative(countsDto?.inDelivery),
      unavailable: _clampNonNegative(countsDto?.unavailable),
    );

    final items =
        dto.items?.map((d) {
          final phone = d.phoneNumber?.trim();
          return DispatcherDriverStatusItemEntity(
            driverId: d.driverId ?? '',
            driverCode: d.driverCode ?? '',
            fullName: d.fullName ?? '',
            phoneNumber: (phone != null && phone.isNotEmpty) ? phone : null,
            avatarUrl: resolveAvatarUrl(d.avatarStorageKey, baseUrl: baseUrl),
            isAvailable: d.isAvailable ?? false,
            operationalStatus: DispatcherDriverStatusType.fromApi(
              d.operationalStatus,
            ),
            rating: d.rating,
            ratingsCount: d.ratingsCount,
            vehicleType: d.vehicleType,
            vehicleModel: d.vehicleModel,
            vehiclePlate: d.vehiclePlate,
          );
        }).toList() ??
        const [];

    final paginationDto = dto.pagination;
    final pagination = DispatcherDriversPaginationEntity(
      pageNumber: paginationDto?.pageNumber ?? 1,
      pageSize: paginationDto?.pageSize ?? 15,
      totalItems: _clampNonNegative(paginationDto?.totalItems),
      totalPages: paginationDto?.totalPages ?? 1,
      hasPreviousPage: paginationDto?.hasPreviousPage ?? false,
      hasNextPage: paginationDto?.hasNextPage ?? false,
    );

    return DispatcherDriversStatusSummaryEntity(
      counts: counts,
      items: items,
      pagination: pagination,
    );
  }

  static UpdateDriverAvailabilityResultEntity toAvailabilityResult(
    UpdateDriverAvailabilityResponseDto dto,
  ) {
    DateTime? parsedDate;
    if (dto.updatedAtUtc != null) {
      parsedDate = DateTime.tryParse(dto.updatedAtUtc!)?.toUtc();
    }
    return UpdateDriverAvailabilityResultEntity(
      driverId: dto.driverId ?? '',
      isAvailable: dto.isAvailable ?? false,
      operationalStatus: DispatcherDriverStatusType.fromApi(
        dto.operationalStatus,
      ),
      updatedAtUtc: parsedDate,
    );
  }
}

extension DispatcherDriversStatusResponseDtoMapper
    on DispatcherDriversStatusResponseDto {
  DispatcherDriversStatusSummaryEntity toEntity({String? baseUrl}) =>
      DispatcherDriversStatusMapper.toEntity(this, baseUrl: baseUrl);
}

extension UpdateDriverAvailabilityResponseDtoMapper
    on UpdateDriverAvailabilityResponseDto {
  UpdateDriverAvailabilityResultEntity toEntity() =>
      DispatcherDriversStatusMapper.toAvailabilityResult(this);
}

import '../../domain/entities/dispatcher_driver_status_item_entity.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import '../../domain/entities/dispatcher_drivers_status_summary_entity.dart';
import '../models/response/dispatcher_drivers_status_response_dto.dart';

extension DispatcherDriversStatusMapper on DispatcherDriversStatusResponseDto {
  DispatcherDriversStatusSummaryEntity toEntity() {
    return DispatcherDriversStatusSummaryEntity(
      restaurantName: restaurantName ?? '',
      role: role ?? '',
      kpis: kpis?.toEntity() ??
          const DispatcherDriversStatusKpisEntity(
            connectedCount: 0,
            inDeliveryCount: 0,
            offlineCount: 0,
            totalCount: 0,
          ),
      drivers: drivers?.map((d) => d.toEntity()).toList() ?? const [],
    );
  }
}

extension DispatcherDriversStatusKpisMapper on DispatcherDriversStatusKpisDto {
  DispatcherDriversStatusKpisEntity toEntity() {
    return DispatcherDriversStatusKpisEntity(
      connectedCount: connectedCount ?? 0,
      inDeliveryCount: inDeliveryCount ?? 0,
      offlineCount: offlineCount ?? 0,
      totalCount: totalCount ?? 0,
    );
  }
}

extension DispatcherDriverStatusItemMapper on DispatcherDriverStatusItemDto {
  DispatcherDriverStatusItemEntity toEntity() {
    return DispatcherDriverStatusItemEntity(
      id: id ?? '',
      name: name ?? '',
      code: code ?? '',
      avatarUrl: avatarUrl ?? '',
      rating: rating ?? 0.0,
      vehicleType: vehicleType ?? '',
      plateNumber: plateNumber ?? '',
      status: _mapStatus(status),
      isAvailable: isAvailable ?? false,
    );
  }

  static DispatcherDriverStatusType _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return DispatcherDriverStatusType.available;
      case 'offline':
        return DispatcherDriverStatusType.offline;
      case 'connected':
      case 'online':
        return DispatcherDriverStatusType.connected;
      default:
        return DispatcherDriverStatusType.available;
    }
  }
}

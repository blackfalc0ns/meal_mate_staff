import '../../domain/entities/dispatcher_home_alert_entity.dart';
import '../../domain/entities/dispatcher_home_area_summary_entity.dart';
import '../../domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import '../../domain/entities/dispatcher_home_operations_status_entity.dart';
import '../../domain/entities/dispatcher_home_overview_entity.dart';
import '../../domain/entities/dispatcher_home_top_driver_entity.dart';
import '../models/response/dispatcher_dashboard_overview_response_dto.dart';
import '../models/response/dispatcher_live_driver_response_dto.dart';

extension DispatcherDashboardOverviewResponseDtoMapper
    on DispatcherDashboardOverviewResponseDto {
  DispatcherHomeOverviewEntity toEntity() {
    final restaurantDto = restaurant;
    final greetingDto = greeting;
    final kpisDto = kpis;
    final operationsDto = operationsStatus;

    return DispatcherHomeOverviewEntity(
      restaurant: DispatcherHomeRestaurantEntity(
        id: restaurantDto?.id ?? '',
        nameAr: restaurantDto?.nameAr ?? '',
        nameEn: restaurantDto?.nameEn ?? '',
        role: restaurantDto?.role ?? '',
      ),
      greeting: DispatcherHomeGreetingEntity(
        title: greetingDto?.title ?? '',
        subtitle: greetingDto?.subtitle ?? '',
      ),
      kpis: DispatcherHomeKpisEntity(
        totalOrdersToday: kpisDto?.totalOrdersToday ?? 0,
        inDeliveryCount: kpisDto?.inDeliveryCount ?? 0,
        pendingAssignmentCount: kpisDto?.pendingAssignmentCount ?? 0,
        activeIssuesCount: kpisDto?.activeIssuesCount ?? 0,
      ),
      operationsStatus: DispatcherHomeOperationsStatusEntity(
        completionRate: operationsDto?.completionRatePercentage ?? 0,
        deliveredCount: operationsDto?.deliveredCount ?? 0,
        deliveredLabel: '',
        inDeliveryCount: operationsDto?.inDeliveryCount ?? 0,
        inDeliveryLabel: '',
        pendingCount: operationsDto?.pendingAssignmentCount ?? 0,
        pendingLabel: '',
        cancelledCount: operationsDto?.cancelledCount ?? 0,
        cancelledLabel: '',
      ),
      topDrivers: (topDrivers ?? const [])
          .map(
            (driver) => DispatcherHomeTopDriverEntity(
              id: driver.driverId ?? '',
              name: driver.fullName ?? '',
              badgeText: driver.badge ?? '',
              rating: driver.rating ?? 0,
              avatarUrl: driver.avatarUrl ?? '',
              completedDeliveriesToday: driver.completedDeliveriesToday ?? 0,
            ),
          )
          .toList(growable: false),
      regions: (regionsSummary ?? const [])
          .asMap()
          .entries
          .map(
            (entry) => DispatcherHomeAreaSummaryEntity(
              id: entry.value.regionId ?? '',
              name: entry.value.regionName ?? '',
              ordersCount: entry.value.ordersCount ?? 0,
              isIncreasing: entry.value.trend?.toLowerCase() == 'up',
              colorType:
                  DispatcherHomeAreaColorType.values[entry.key %
                      DispatcherHomeAreaColorType.values.length],
              percentageChange: entry.value.percentageChange ?? 0,
            ),
          )
          .toList(growable: false),
      activeIssues: DispatcherHomeActiveIssuesEntity(
        count: activeIssues?.count ?? 0,
        summaryAr: activeIssues?.summaryAr ?? '',
        summaryEn: activeIssues?.summaryEn ?? '',
        items: (activeIssues?.issues ?? const [])
            .map(
              (issue) => DispatcherHomeIssueEntity(
                id: issue.id ?? '',
                type: issue.type ?? '',
                severity: issue.severity ?? '',
                orderId: issue.orderId,
                driverId: issue.driverId,
                driverName: issue.driverName ?? '',
                message: issue.message ?? '',
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

extension DispatcherLiveDriverResponseDtoMapper
    on DispatcherLiveDriverResponseDto {
  DispatcherHomeMapDriverPinEntity toEntity() {
    return DispatcherHomeMapDriverPinEntity(
      id: driverId ?? '',
      fullName: fullName ?? '',
      phone: phone ?? '',
      plateNumber: plateNumber ?? '',
      statusText: statusLabelAr ?? statusLabelEn ?? '',
      status: switch (status?.toLowerCase()) {
        'enroutetocustomer' => DispatcherHomePinStatus.enRouteToCustomer,
        'indelivery' => DispatcherHomePinStatus.inDelivery,
        'onbreak' => DispatcherHomePinStatus.onBreak,
        'available' => DispatcherHomePinStatus.available,
        _ => DispatcherHomePinStatus.unknown,
      },
      avatarUrl: avatarUrl ?? '',
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      heading: heading ?? 0,
      speedKmh: speedKmh ?? 0,
      activeOrderId: activeOrderId,
      customerAddress: customerAddress,
      updatedAtUtc: updatedAtUtc,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatcher_dashboard_overview_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatcherDashboardOverviewResponseDto
_$DispatcherDashboardOverviewResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherDashboardOverviewResponseDto(
  restaurant: json['restaurant'] == null
      ? null
      : DispatcherRestaurantResponseDto.fromJson(
          json['restaurant'] as Map<String, dynamic>,
        ),
  greeting: json['greeting'] == null
      ? null
      : DispatcherGreetingResponseDto.fromJson(
          json['greeting'] as Map<String, dynamic>,
        ),
  kpis: json['kpis'] == null
      ? null
      : DispatcherKpisResponseDto.fromJson(
          json['kpis'] as Map<String, dynamic>,
        ),
  operationsStatus: json['operationsStatus'] == null
      ? null
      : DispatcherOperationsStatusResponseDto.fromJson(
          json['operationsStatus'] as Map<String, dynamic>,
        ),
  topDrivers: (json['topDrivers'] as List<dynamic>?)
      ?.map(
        (e) =>
            DispatcherTopDriverResponseDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  regionsSummary: (json['regionsSummary'] as List<dynamic>?)
      ?.map(
        (e) => DispatcherRegionSummaryResponseDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  activeIssues: json['activeIssues'] == null
      ? null
      : DispatcherActiveIssuesResponseDto.fromJson(
          json['activeIssues'] as Map<String, dynamic>,
        ),
);

DispatcherRestaurantResponseDto _$DispatcherRestaurantResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherRestaurantResponseDto(
  id: json['id'] as String?,
  nameAr: json['nameAr'] as String?,
  nameEn: json['nameEn'] as String?,
  role: json['role'] as String?,
);

DispatcherGreetingResponseDto _$DispatcherGreetingResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherGreetingResponseDto(
  title: json['title'] as String?,
  subtitle: json['subtitle'] as String?,
);

DispatcherKpisResponseDto _$DispatcherKpisResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherKpisResponseDto(
  totalOrdersToday: (json['totalOrdersToday'] as num?)?.toInt(),
  inDeliveryCount: (json['inDeliveryCount'] as num?)?.toInt(),
  pendingAssignmentCount: (json['pendingAssignmentCount'] as num?)?.toInt(),
  activeIssuesCount: (json['activeIssuesCount'] as num?)?.toInt(),
);

DispatcherOperationsStatusResponseDto
_$DispatcherOperationsStatusResponseDtoFromJson(Map<String, dynamic> json) =>
    DispatcherOperationsStatusResponseDto(
      completionRatePercentage: (json['completionRatePercentage'] as num?)
          ?.toDouble(),
      deliveredCount: (json['deliveredCount'] as num?)?.toInt(),
      inDeliveryCount: (json['inDeliveryCount'] as num?)?.toInt(),
      pendingAssignmentCount: (json['pendingAssignmentCount'] as num?)?.toInt(),
      cancelledCount: (json['cancelledCount'] as num?)?.toInt(),
    );

DispatcherTopDriverResponseDto _$DispatcherTopDriverResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherTopDriverResponseDto(
  driverId: json['driverId'] as String?,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  badge: json['badge'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  completedDeliveriesToday: (json['completedDeliveriesToday'] as num?)?.toInt(),
);

DispatcherRegionSummaryResponseDto _$DispatcherRegionSummaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherRegionSummaryResponseDto(
  regionId: json['regionId'] as String?,
  regionName: json['regionName'] as String?,
  ordersCount: (json['ordersCount'] as num?)?.toInt(),
  trend: json['trend'] as String?,
  percentageChange: (json['percentageChange'] as num?)?.toDouble(),
);

DispatcherActiveIssuesResponseDto _$DispatcherActiveIssuesResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherActiveIssuesResponseDto(
  count: (json['count'] as num?)?.toInt(),
  summaryAr: json['summaryAr'] as String?,
  summaryEn: json['summaryEn'] as String?,
  issues: (json['issues'] as List<dynamic>?)
      ?.map(
        (e) => DispatcherIssueResponseDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

DispatcherIssueResponseDto _$DispatcherIssueResponseDtoFromJson(
  Map<String, dynamic> json,
) => DispatcherIssueResponseDto(
  id: json['id'] as String?,
  type: json['type'] as String?,
  severity: json['severity'] as String?,
  orderId: json['orderId'] as String?,
  driverId: json['driverId'] as String?,
  driverName: json['driverName'] as String?,
  message: json['message'] as String?,
);

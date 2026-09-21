import 'package:json_annotation/json_annotation.dart';

part 'dispatcher_dashboard_overview_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DispatcherDashboardOverviewResponseDto {
  const DispatcherDashboardOverviewResponseDto({
    this.restaurant,
    this.greeting,
    this.kpis,
    this.operationsStatus,
    this.topDrivers,
    this.regionsSummary,
    this.activeIssues,
  });

  factory DispatcherDashboardOverviewResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherDashboardOverviewResponseDtoFromJson(json);

  final DispatcherRestaurantResponseDto? restaurant;
  final DispatcherGreetingResponseDto? greeting;
  final DispatcherKpisResponseDto? kpis;
  final DispatcherOperationsStatusResponseDto? operationsStatus;
  final List<DispatcherTopDriverResponseDto>? topDrivers;
  final List<DispatcherRegionSummaryResponseDto>? regionsSummary;
  final DispatcherActiveIssuesResponseDto? activeIssues;
}

@JsonSerializable(createToJson: false)
class DispatcherRestaurantResponseDto {
  const DispatcherRestaurantResponseDto({
    this.id,
    this.nameAr,
    this.nameEn,
    this.role,
  });
  factory DispatcherRestaurantResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherRestaurantResponseDtoFromJson(json);
  final String? id;
  final String? nameAr;
  final String? nameEn;
  final String? role;
}

@JsonSerializable(createToJson: false)
class DispatcherGreetingResponseDto {
  const DispatcherGreetingResponseDto({this.title, this.subtitle});
  factory DispatcherGreetingResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherGreetingResponseDtoFromJson(json);
  final String? title;
  final String? subtitle;
}

@JsonSerializable(createToJson: false)
class DispatcherKpisResponseDto {
  const DispatcherKpisResponseDto({
    this.totalOrdersToday,
    this.inDeliveryCount,
    this.pendingAssignmentCount,
    this.activeIssuesCount,
  });
  factory DispatcherKpisResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherKpisResponseDtoFromJson(json);
  final int? totalOrdersToday;
  final int? inDeliveryCount;
  final int? pendingAssignmentCount;
  final int? activeIssuesCount;
}

@JsonSerializable(createToJson: false)
class DispatcherOperationsStatusResponseDto {
  const DispatcherOperationsStatusResponseDto({
    this.completionRatePercentage,
    this.deliveredCount,
    this.inDeliveryCount,
    this.pendingAssignmentCount,
    this.cancelledCount,
  });
  factory DispatcherOperationsStatusResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherOperationsStatusResponseDtoFromJson(json);
  final double? completionRatePercentage;
  final int? deliveredCount;
  final int? inDeliveryCount;
  final int? pendingAssignmentCount;
  final int? cancelledCount;
}

@JsonSerializable(createToJson: false)
class DispatcherTopDriverResponseDto {
  const DispatcherTopDriverResponseDto({
    this.driverId,
    this.fullName,
    this.avatarUrl,
    this.badge,
    this.rating,
    this.completedDeliveriesToday,
  });
  factory DispatcherTopDriverResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherTopDriverResponseDtoFromJson(json);
  final String? driverId;
  final String? fullName;
  final String? avatarUrl;
  final String? badge;
  final double? rating;
  final int? completedDeliveriesToday;
}

@JsonSerializable(createToJson: false)
class DispatcherRegionSummaryResponseDto {
  const DispatcherRegionSummaryResponseDto({
    this.regionId,
    this.regionName,
    this.ordersCount,
    this.trend,
    this.percentageChange,
  });
  factory DispatcherRegionSummaryResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherRegionSummaryResponseDtoFromJson(json);
  final String? regionId;
  final String? regionName;
  final int? ordersCount;
  final String? trend;
  final double? percentageChange;
}

@JsonSerializable(createToJson: false)
class DispatcherActiveIssuesResponseDto {
  const DispatcherActiveIssuesResponseDto({
    this.count,
    this.summaryAr,
    this.summaryEn,
    this.issues,
  });
  factory DispatcherActiveIssuesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$DispatcherActiveIssuesResponseDtoFromJson(json);
  final int? count;
  final String? summaryAr;
  final String? summaryEn;
  final List<DispatcherIssueResponseDto>? issues;
}

@JsonSerializable(createToJson: false)
class DispatcherIssueResponseDto {
  const DispatcherIssueResponseDto({
    this.id,
    this.type,
    this.severity,
    this.orderId,
    this.driverId,
    this.driverName,
    this.message,
  });
  factory DispatcherIssueResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DispatcherIssueResponseDtoFromJson(json);
  final String? id;
  final String? type;
  final String? severity;
  final String? orderId;
  final String? driverId;
  final String? driverName;
  final String? message;
}

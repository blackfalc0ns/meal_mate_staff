import '../../domain/entities/driver_performance_comparison_entity.dart';
import '../../domain/entities/driver_performance_delay_level.dart';
import '../../domain/entities/driver_performance_distribution_category.dart';
import '../../domain/entities/driver_performance_distribution_entity.dart';
import '../../domain/entities/driver_performance_distribution_item_entity.dart';
import '../../domain/entities/driver_performance_driver_status.dart';
import '../../domain/entities/driver_performance_kpis_entity.dart';
import '../../domain/entities/driver_performance_overview_entity.dart';
import '../../domain/entities/driver_performance_period.dart';
import '../../domain/entities/driver_performance_record_entity.dart';
import '../../domain/entities/driver_podium_entry_entity.dart';
import '../models/response/driver_performance_comparison_response_dto.dart';
import '../models/response/driver_performance_overview_response_dto.dart';

extension DriverPerformanceOverviewResponseDtoMapper
    on DriverPerformanceOverviewResponseDto {
  DriverPerformanceOverviewEntity toEntity() {
    return DriverPerformanceOverviewEntity(
      period: DriverPerformancePeriod.fromApi(period),
      periodText: periodText ?? '',
      dateRangeText: dateRangeText ?? '',
      fromDate: _parseDateTime(fromDate),
      toDate: _parseDateTime(toDate),
      kpis:
          kpis?.toEntity() ??
          const DriverPerformanceKpisEntity(
            totalBoxes: 0,
            deliveredCount: 0,
            deliveredPercentage: 0.0,
            avgDelayMinutes: 0,
            overallRating: 0.0,
            failedCount: 0,
            failedPercentage: 0.0,
          ),
      distribution:
          distribution?.toEntity() ??
          const DriverPerformanceDistributionEntity(
            totalBoxes: 0,
            segments: <DriverPerformanceDistributionItemEntity>[],
          ),
      topDrivers:
          topDrivers?.map((dto) => dto.toEntity()).toList(growable: false) ??
          const <DriverPodiumEntryEntity>[],
      driversTable:
          driversTable?.map((dto) => dto.toEntity()).toList(growable: false) ??
          const <DriverPerformanceRecordEntity>[],
    );
  }
}

extension DriverPerformanceKpisResponseDtoMapper
    on DriverPerformanceKpisResponseDto {
  DriverPerformanceKpisEntity toEntity() {
    return DriverPerformanceKpisEntity(
      totalBoxes: totalBoxes ?? 0,
      deliveredCount: deliveredCount ?? 0,
      deliveredPercentage: deliveredPercentage ?? 0.0,
      avgDelayMinutes: avgDelayMinutes ?? 0,
      overallRating: overallRating ?? 0.0,
      failedCount: failedCount ?? 0,
      failedPercentage: failedPercentage ?? 0.0,
      totalBoxesText: totalBoxesText,
      deliveredCountText: deliveredCountText,
      deliveredPercentageText: deliveredPercentageText,
      avgDelayText: avgDelayText,
      overallRatingText: overallRatingText,
      failedCountText: failedCountText,
      failedPercentageText: failedPercentageText,
    );
  }
}

extension DriverPerformanceDistributionResponseDtoMapper
    on DriverPerformanceDistributionResponseDto {
  DriverPerformanceDistributionEntity toEntity() {
    return DriverPerformanceDistributionEntity(
      totalBoxes: totalBoxes ?? 0,
      segments:
          segments?.map((dto) => dto.toEntity()).toList(growable: false) ??
          const <DriverPerformanceDistributionItemEntity>[],
    );
  }
}

extension DriverPerformanceDistributionSegmentResponseDtoMapper
    on DriverPerformanceDistributionSegmentResponseDto {
  DriverPerformanceDistributionItemEntity toEntity() {
    return DriverPerformanceDistributionItemEntity(
      id: id ?? '',
      category: DriverPerformanceDistributionCategory.fromApi(key),
      count: count ?? 0,
      percentage: percentage ?? 0.0,
      name: name,
      colorHex: color,
    );
  }
}

extension DriverPerformancePodiumResponseDtoMapper
    on DriverPerformancePodiumResponseDto {
  DriverPodiumEntryEntity toEntity() {
    return DriverPodiumEntryEntity(
      rank: rank ?? 0,
      driverId: driverId,
      driverCode: driverCode,
      name: name ?? '',
      rating: rating ?? 0.0,
      avatarUrl: avatarUrl,
    );
  }
}

extension DriverPerformanceTableRowResponseDtoMapper
    on DriverPerformanceTableRowResponseDto {
  DriverPerformanceRecordEntity toEntity() {
    return DriverPerformanceRecordEntity(
      driverId: driverId ?? '',
      driverCode: driverCode ?? '',
      fullName: fullName ?? '',
      avatarUrl: avatarUrl,
      status: DriverPerformanceDriverStatus.fromApi(status),
      statusDotColorKey: statusDotColorKey,
      deliveredCount: deliveredCount ?? 0,
      deliveredCountText: deliveredCountText,
      deliveredPercentage: deliveredPercentage ?? 0.0,
      deliveredPercentageText: deliveredPercentageText,
      avgDelayMinutes: avgDelayMinutes ?? 0,
      avgDelayText: avgDelayText,
      delayLevel: DriverPerformanceDelayLevelX.fromApi(delayLevel),
      failedDeliveryCount: failedDeliveryCount ?? 0,
      failedDeliveryCountText: failedDeliveryCountText,
      failedDeliveryPercentage: failedDeliveryPercentage ?? 0.0,
      failedDeliveryPercentageText: failedDeliveryPercentageText,
      rating: rating ?? 0.0,
      ratingText: ratingText,
    );
  }
}

extension DriverPerformanceComparisonResponseDtoMapper
    on DriverPerformanceComparisonResponseDto {
  DriverPerformanceComparisonEntity toEntity() {
    return DriverPerformanceComparisonEntity(
      period: DriverPerformancePeriod.fromApi(period),
      periodText: periodText ?? '',
      dateRangeText: dateRangeText ?? '',
      fromDate: _parseDateTime(fromDate),
      toDate: _parseDateTime(toDate),
      drivers:
          drivers?.map((dto) => dto.toEntity()).toList(growable: false) ??
          const <DriverComparisonRecordEntity>[],
    );
  }
}

extension DriverComparisonDriverResponseDtoMapper
    on DriverComparisonDriverResponseDto {
  DriverComparisonRecordEntity toEntity() {
    return DriverComparisonRecordEntity(
      driverId: driverId ?? '',
      driverCode: driverCode ?? '',
      fullName: fullName ?? '',
      avatarUrl: avatarUrl,
      totalAssigned: totalAssigned ?? 0,
      totalAssignedText: totalAssignedText,
      deliveredCount: deliveredCount ?? 0,
      deliveredCountText: deliveredCountText,
      deliveredPercentage: deliveredPercentage ?? 0.0,
      deliveredPercentageText: deliveredPercentageText,
      onTimePercentage: onTimePercentage ?? 0.0,
      onTimePercentageText: onTimePercentageText,
      avgDelayMinutes: avgDelayMinutes ?? 0,
      avgDelayText: avgDelayText,
      delayLevel: DriverPerformanceDelayLevelX.fromApi(delayLevel),
      rating: rating,
      ratingText: ratingText,
      failedCount: failedCount ?? 0,
      failedCountText: failedCountText,
      failedPercentage: failedPercentage ?? 0.0,
      failedPercentageText: failedPercentageText,
      totalDistanceKm: totalDistanceKm,
      totalDistanceKmText: totalDistanceKmText,
    );
  }
}

DateTime? _parseDateTime(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return null;
  try {
    final parsed = DateTime.parse(dateStr.trim());
    return parsed.isUtc
        ? parsed
        : DateTime.utc(
            parsed.year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
            parsed.second,
            parsed.millisecond,
          );
  } catch (_) {
    return null;
  }
}

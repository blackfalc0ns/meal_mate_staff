import 'operation_status.dart';
import 'operations_date_preset.dart';

class OperationsQueryEntity {
  const OperationsQueryEntity({
    this.restaurantId,
    this.status = OperationStatus.all,
    this.search = '',
    this.datePreset = OperationsDatePreset.last7Days,
    this.fromDateUtc,
    this.toDateUtc,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  final String? restaurantId;
  final OperationStatus status;
  final String search;
  final OperationsDatePreset datePreset;
  final DateTime? fromDateUtc;
  final DateTime? toDateUtc;
  final int pageNumber;
  final int pageSize;

  bool get isValid {
    if (pageNumber < 1) return false;
    if (pageSize < 1 || pageSize > 50) return false;
    if (datePreset == OperationsDatePreset.custom) {
      if (fromDateUtc == null || toDateUtc == null) return false;
      if (fromDateUtc!.isAfter(toDateUtc!)) return false;
    }
    return true;
  }

  OperationsQueryEntity resetToFirstPage() {
    return copyWith(pageNumber: 1);
  }

  OperationsQueryEntity copyWith({
    String? restaurantId,
    bool clearRestaurantId = false,
    OperationStatus? status,
    String? search,
    OperationsDatePreset? datePreset,
    DateTime? fromDateUtc,
    DateTime? toDateUtc,
    bool clearCustomDates = false,
    int? pageNumber,
    int? pageSize,
  }) {
    return OperationsQueryEntity(
      restaurantId: clearRestaurantId
          ? null
          : (restaurantId ?? this.restaurantId),
      status: status ?? this.status,
      search: search ?? this.search,
      datePreset: datePreset ?? this.datePreset,
      fromDateUtc: clearCustomDates ? null : (fromDateUtc ?? this.fromDateUtc),
      toDateUtc: clearCustomDates ? null : (toDateUtc ?? this.toDateUtc),
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationsQueryEntity &&
          runtimeType == other.runtimeType &&
          restaurantId == other.restaurantId &&
          status == other.status &&
          search == other.search &&
          datePreset == other.datePreset &&
          fromDateUtc == other.fromDateUtc &&
          toDateUtc == other.toDateUtc &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize;

  @override
  int get hashCode => Object.hash(
    restaurantId,
    status,
    search,
    datePreset,
    fromDateUtc,
    toDateUtc,
    pageNumber,
    pageSize,
  );
}

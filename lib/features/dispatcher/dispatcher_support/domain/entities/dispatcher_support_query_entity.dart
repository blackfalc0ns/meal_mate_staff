import 'dispatcher_support_date_preset.dart';
import 'dispatcher_support_status.dart';

class DispatcherSupportQueryEntity {
  const DispatcherSupportQueryEntity({
    this.area,
    this.status = DispatcherSupportStatus.open,
    this.search = '',
    this.datePreset = DispatcherSupportDatePreset.last7Days,
    this.fromDateUtc,
    this.toDateUtc,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  final String? area;
  final DispatcherSupportStatus status;
  final String search;
  final DispatcherSupportDatePreset datePreset;
  final DateTime? fromDateUtc;
  final DateTime? toDateUtc;
  final int pageNumber;
  final int pageSize;

  String get apiStatus {
    switch (status) {
      case DispatcherSupportStatus.open:
        return 'Open';
      case DispatcherSupportStatus.inProgress:
        return 'InProgress';
      case DispatcherSupportStatus.resolved:
        return 'Resolved';
    }
  }

  String get apiDatePreset => datePreset.apiValue;

  DispatcherSupportQueryEntity resetToFirstPage() {
    return copyWith(pageNumber: 1);
  }

  DispatcherSupportQueryEntity copyWith({
    Object? area = _sentinel,
    DispatcherSupportStatus? status,
    String? search,
    DispatcherSupportDatePreset? datePreset,
    Object? fromDateUtc = _sentinel,
    Object? toDateUtc = _sentinel,
    int? pageNumber,
    int? pageSize,
  }) {
    return DispatcherSupportQueryEntity(
      area: identical(area, _sentinel) ? this.area : area as String?,
      status: status ?? this.status,
      search: search ?? this.search,
      datePreset: datePreset ?? this.datePreset,
      fromDateUtc: identical(fromDateUtc, _sentinel)
          ? this.fromDateUtc
          : fromDateUtc as DateTime?,
      toDateUtc: identical(toDateUtc, _sentinel)
          ? this.toDateUtc
          : toDateUtc as DateTime?,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DispatcherSupportQueryEntity &&
        other.area == area &&
        other.status == status &&
        other.search == search &&
        other.datePreset == datePreset &&
        other.fromDateUtc == fromDateUtc &&
        other.toDateUtc == toDateUtc &&
        other.pageNumber == pageNumber &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode => Object.hash(
    area,
    status,
    search,
    datePreset,
    fromDateUtc,
    toDateUtc,
    pageNumber,
    pageSize,
  );
}

const Object _sentinel = Object();

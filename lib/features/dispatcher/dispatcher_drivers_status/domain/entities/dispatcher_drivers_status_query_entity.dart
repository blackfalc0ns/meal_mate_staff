import 'dispatcher_driver_status_type.dart';
import 'dispatcher_drivers_status_sort.dart';

class DispatcherDriversStatusQueryEntity {
  const DispatcherDriversStatusQueryEntity({
    this.search,
    this.status,
    this.sortBy = DispatcherDriversStatusSort.name,
    this.pageNumber = 1,
    this.pageSize = 15,
  });

  final String? search;
  final DispatcherDriverStatusType? status;
  final DispatcherDriversStatusSort sortBy;
  final int pageNumber;
  final int pageSize;

  DispatcherDriversStatusQueryEntity copyWith({
    String? search,
    bool clearSearch = false,
    DispatcherDriverStatusType? status,
    bool clearStatus = false,
    DispatcherDriversStatusSort? sortBy,
    int? pageNumber,
    int? pageSize,
  }) {
    return DispatcherDriversStatusQueryEntity(
      search: clearSearch ? null : (search ?? this.search),
      status: clearStatus ? null : (status ?? this.status),
      sortBy: sortBy ?? this.sortBy,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversStatusQueryEntity &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          status == other.status &&
          sortBy == other.sortBy &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize;

  @override
  int get hashCode => Object.hash(search, status, sortBy, pageNumber, pageSize);
}

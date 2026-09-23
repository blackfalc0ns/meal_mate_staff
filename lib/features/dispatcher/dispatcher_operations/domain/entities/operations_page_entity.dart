import 'operation_item_entity.dart';
import 'operations_counters_entity.dart';
import 'operations_pagination_entity.dart';

class OperationsPageEntity {
  const OperationsPageEntity({
    required this.counters,
    required this.operations,
    required this.pagination,
  });

  final OperationsCountersEntity counters;
  final List<OperationItemEntity> operations;
  final OperationsPaginationEntity pagination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationsPageEntity &&
          runtimeType == other.runtimeType &&
          counters == other.counters &&
          pagination == other.pagination &&
          _listEquals(operations, other.operations);

  @override
  int get hashCode =>
      Object.hash(counters, pagination, Object.hashAll(operations));

  static bool _listEquals(
    List<OperationItemEntity> a,
    List<OperationItemEntity> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

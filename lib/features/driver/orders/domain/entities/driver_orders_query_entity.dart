import 'driver_orders_filter.dart';

class DriverOrdersQueryEntity {
  const DriverOrdersQueryEntity({
    this.search = '',
    this.filter = DriverOrdersFilter.all,
  });

  final String search;
  final DriverOrdersFilter filter;

  DriverOrdersQueryEntity copyWith({
    String? search,
    DriverOrdersFilter? filter,
  }) {
    return DriverOrdersQueryEntity(
      search: search ?? this.search,
      filter: filter ?? this.filter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverOrdersQueryEntity &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          filter == other.filter;

  @override
  int get hashCode => Object.hash(search, filter);
}

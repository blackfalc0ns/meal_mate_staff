enum DispatcherHomeAreaColorType {
  salmiya,
  hawally,
  jahra,
  capital,
}

class DispatcherHomeAreaSummaryEntity {
  const DispatcherHomeAreaSummaryEntity({
    required this.id,
    required this.name,
    required this.ordersCount,
    required this.isIncreasing,
    required this.colorType,
  });

  final String id;
  final String name;
  final int ordersCount;
  final bool isIncreasing;
  final DispatcherHomeAreaColorType colorType;
}

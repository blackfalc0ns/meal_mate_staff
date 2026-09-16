class DriverAssignedBoxEntity {
  const DriverAssignedBoxEntity({
    required this.boxId,
    required this.orderCode,
    required this.mealCount,
    required this.area,
    required this.isLoaded,
  });

  final String boxId;
  final String orderCode;
  final int mealCount;
  final String area;
  final bool isLoaded;

  DriverAssignedBoxEntity copyWith({
    String? boxId,
    String? orderCode,
    int? mealCount,
    String? area,
    bool? isLoaded,
  }) {
    return DriverAssignedBoxEntity(
      boxId: boxId ?? this.boxId,
      orderCode: orderCode ?? this.orderCode,
      mealCount: mealCount ?? this.mealCount,
      area: area ?? this.area,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

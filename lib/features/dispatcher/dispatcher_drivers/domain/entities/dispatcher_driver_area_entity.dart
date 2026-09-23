class DispatcherDriverAreaEntity {
  const DispatcherDriverAreaEntity({
    required this.name,
    required this.areaKey,
    required this.driverCount,
    this.isSelected = false,
  });

  final String name;
  final String areaKey;
  final int driverCount;
  final bool isSelected;

  DispatcherDriverAreaEntity copyWith({
    String? name,
    String? areaKey,
    int? driverCount,
    bool? isSelected,
  }) {
    return DispatcherDriverAreaEntity(
      name: name ?? this.name,
      areaKey: areaKey ?? this.areaKey,
      driverCount: driverCount ?? this.driverCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverAreaEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          areaKey == other.areaKey &&
          driverCount == other.driverCount &&
          isSelected == other.isSelected;

  @override
  int get hashCode =>
      name.hashCode ^
      areaKey.hashCode ^
      driverCount.hashCode ^
      isSelected.hashCode;
}

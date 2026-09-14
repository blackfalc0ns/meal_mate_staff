class DriverFilterCriteriaEntity {
  const DriverFilterCriteriaEntity({
    this.selectedArea,
    this.selectedStatus,
    this.minRating,
    this.distanceKm,
    this.completedOrders,
    this.searchQuery,
  });

  final String? selectedArea;
  final String? selectedStatus;
  final double? minRating;
  final double? distanceKm;
  final int? completedOrders;
  final String? searchQuery;

  factory DriverFilterCriteriaEntity.initial() {
    return const DriverFilterCriteriaEntity(
      selectedArea: null,
      selectedStatus: null,
      minRating: null,
      distanceKm: null,
      completedOrders: null,
      searchQuery: null,
    );
  }

  bool get isDefault =>
      selectedArea == null &&
      selectedStatus == null &&
      minRating == null &&
      distanceKm == null &&
      completedOrders == null &&
      (searchQuery == null || searchQuery!.isEmpty);

  DriverFilterCriteriaEntity copyWith({
    String? selectedArea,
    String? selectedStatus,
    double? minRating,
    double? distanceKm,
    int? completedOrders,
    String? searchQuery,
    bool clearArea = false,
    bool clearStatus = false,
    bool clearRating = false,
    bool clearDistance = false,
    bool clearOrders = false,
    bool clearSearch = false,
  }) {
    return DriverFilterCriteriaEntity(
      selectedArea: clearArea ? null : (selectedArea ?? this.selectedArea),
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      distanceKm: clearDistance ? null : (distanceKm ?? this.distanceKm),
      completedOrders: clearOrders
          ? null
          : (completedOrders ?? this.completedOrders),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverFilterCriteriaEntity &&
          runtimeType == other.runtimeType &&
          selectedArea == other.selectedArea &&
          selectedStatus == other.selectedStatus &&
          minRating == other.minRating &&
          distanceKm == other.distanceKm &&
          completedOrders == other.completedOrders &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      selectedArea.hashCode ^
      selectedStatus.hashCode ^
      minRating.hashCode ^
      distanceKm.hashCode ^
      completedOrders.hashCode ^
      searchQuery.hashCode;
}

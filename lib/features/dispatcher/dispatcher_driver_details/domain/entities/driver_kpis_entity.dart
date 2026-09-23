class DriverKpisEntity {
  const DriverKpisEntity({
    required this.performanceRating,
    required this.avgDelayMinutes,
    required this.deliveredTodayCount,
    required this.activeBoxesCount,
  });

  final double performanceRating;
  final int avgDelayMinutes;
  final int deliveredTodayCount;
  final int activeBoxesCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverKpisEntity &&
          runtimeType == other.runtimeType &&
          performanceRating == other.performanceRating &&
          avgDelayMinutes == other.avgDelayMinutes &&
          deliveredTodayCount == other.deliveredTodayCount &&
          activeBoxesCount == other.activeBoxesCount;

  @override
  int get hashCode => Object.hash(
        performanceRating,
        avgDelayMinutes,
        deliveredTodayCount,
        activeBoxesCount,
      );
}

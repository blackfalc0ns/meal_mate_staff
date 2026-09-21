class DispatcherHomeTopDriverEntity {
  const DispatcherHomeTopDriverEntity({
    required this.id,
    required this.name,
    required this.badgeText,
    required this.rating,
    required this.avatarUrl,
    this.completedDeliveriesToday = 0,
  });

  final String id;
  final String name;
  final String badgeText;
  final double rating;
  final String avatarUrl;
  final int completedDeliveriesToday;
}

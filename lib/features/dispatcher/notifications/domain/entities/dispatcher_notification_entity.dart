enum DispatcherNotificationType {
  newBox,
  boxProblem,
  driverCompleted,
  replacementBox,
  performanceAlert,
  tripUpdate,
  delayedBox,
}

class DispatcherNotificationEntity {
  const DispatcherNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.iconAsset,
    required this.isUnread,
    this.isArchived = false,
  });

  final String id;
  final DispatcherNotificationType type;
  final String title;
  final String description;
  final String timeAgo;
  final String iconAsset;
  final bool isUnread;
  final bool isArchived;

  DispatcherNotificationEntity copyWith({
    String? id,
    DispatcherNotificationType? type,
    String? title,
    String? description,
    String? timeAgo,
    String? iconAsset,
    bool? isUnread,
    bool? isArchived,
  }) {
    return DispatcherNotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      iconAsset: iconAsset ?? this.iconAsset,
      isUnread: isUnread ?? this.isUnread,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

enum DispatcherNotificationType {
  newBox,
  boxProblem,
  driverCompleted,
  replacementBox,
  performanceAlert,
  tripUpdate,
  delayedBox,
  driverSupportIssue,
  driverSupportIssueResolved,
  driverSupportHandover,
  other,
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
    this.section,
    this.subjectId,
    this.deepLink,
    this.sentAtUtc,
    this.rawType,
  });

  final String id;
  final DispatcherNotificationType type;
  final String title;
  final String description;
  final String timeAgo;
  final String iconAsset;
  final bool isUnread;
  final bool isArchived;
  final String? section;
  final String? subjectId;
  final String? deepLink;
  final DateTime? sentAtUtc;
  final String? rawType;

  bool get isRead => !isUnread;

  DispatcherNotificationEntity copyWith({
    String? id,
    DispatcherNotificationType? type,
    String? title,
    String? description,
    String? timeAgo,
    String? iconAsset,
    bool? isUnread,
    bool? isArchived,
    String? section,
    String? subjectId,
    String? deepLink,
    DateTime? sentAtUtc,
    String? rawType,
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
      section: section ?? this.section,
      subjectId: subjectId ?? this.subjectId,
      deepLink: deepLink ?? this.deepLink,
      sentAtUtc: sentAtUtc ?? this.sentAtUtc,
      rawType: rawType ?? this.rawType,
    );
  }
}

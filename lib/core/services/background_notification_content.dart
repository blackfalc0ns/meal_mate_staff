class BackgroundNotificationContent {
  const BackgroundNotificationContent({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

BackgroundNotificationContent? resolveBackgroundNotificationContent({
  required bool hasSystemNotification,
  required Map<String, dynamic> data,
}) {
  if (hasSystemNotification) return null;

  return BackgroundNotificationContent(
    title: data['title']?.toString().trim().isNotEmpty == true
        ? data['title'].toString()
        : 'MealMate',
    body: data['body']?.toString() ?? '',
  );
}

class DispatcherHomeAlertEntity {
  const DispatcherHomeAlertEntity({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class DispatcherHomeIssueEntity {
  const DispatcherHomeIssueEntity({
    required this.id,
    required this.type,
    required this.severity,
    required this.driverName,
    required this.message,
    this.orderId,
    this.driverId,
  });

  final String id;
  final String type;
  final String severity;
  final String? orderId;
  final String? driverId;
  final String driverName;
  final String message;
}

class DispatcherHomeActiveIssuesEntity {
  const DispatcherHomeActiveIssuesEntity({
    required this.count,
    required this.summaryAr,
    required this.summaryEn,
    required this.items,
  });

  final int count;
  final String summaryAr;
  final String summaryEn;
  final List<DispatcherHomeIssueEntity> items;
}

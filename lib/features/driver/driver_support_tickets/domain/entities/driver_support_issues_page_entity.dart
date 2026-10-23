import 'driver_support_ticket_entity.dart';

class DriverSupportIssuesPageEntity {
  const DriverSupportIssuesPageEntity({
    this.allCount = 0,
    this.underReviewCount = 0,
    this.awaitingReplyCount = 0,
    this.resolvedCount = 0,
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.issues = const [],
  });

  final int allCount;
  final int underReviewCount;
  final int awaitingReplyCount;
  final int resolvedCount;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final List<DriverSupportTicketEntity> issues;

  bool get hasMore => (pageNumber * pageSize) < totalCount;
}

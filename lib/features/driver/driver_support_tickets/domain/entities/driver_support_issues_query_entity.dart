import 'driver_support_ticket_status.dart';

class DriverSupportIssuesQueryEntity {
  const DriverSupportIssuesQueryEntity({
    this.filter = DriverSupportTicketFilter.all,
    this.search,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  final DriverSupportTicketFilter filter;
  final String? search;
  final int pageNumber;
  final int pageSize;

  String get backendStatus => switch (filter) {
        DriverSupportTicketFilter.all => 'All',
        DriverSupportTicketFilter.underReview => 'UnderReview',
        DriverSupportTicketFilter.awaitingResponse => 'AwaitingReply',
        DriverSupportTicketFilter.resolved => 'Resolved',
      };

  DriverSupportIssuesQueryEntity copyWith({
    DriverSupportTicketFilter? filter,
    String? search,
    int? pageNumber,
    int? pageSize,
  }) {
    return DriverSupportIssuesQueryEntity(
      filter: filter ?? this.filter,
      search: search ?? this.search,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

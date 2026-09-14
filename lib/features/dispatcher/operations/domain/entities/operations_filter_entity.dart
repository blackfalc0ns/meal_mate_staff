import 'operation_status.dart';

class OperationsFilterEntity {
  const OperationsFilterEntity({
    this.searchQuery = '',
    this.selectedStatus,
    this.dateRangeLabel = 'آخر 7 أيام',
    this.totalCount = 128,
    this.completedCount = 96,
    this.cancelledCount = 3,
    this.failedCount = 7,
    this.reassignedCount = 17,
    this.currentPage = 1,
    this.totalPages = 13,
  });

  final String searchQuery;
  final OperationStatus? selectedStatus;
  final String dateRangeLabel;
  final int totalCount;
  final int completedCount;
  final int cancelledCount;
  final int failedCount;
  final int reassignedCount;
  final int currentPage;
  final int totalPages;

  OperationsFilterEntity copyWith({
    String? searchQuery,
    OperationStatus? selectedStatus,
    bool clearStatus = false,
    String? dateRangeLabel,
    int? totalCount,
    int? completedCount,
    int? cancelledCount,
    int? failedCount,
    int? reassignedCount,
    int? currentPage,
    int? totalPages,
  }) {
    return OperationsFilterEntity(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus:
          clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      failedCount: failedCount ?? this.failedCount,
      reassignedCount: reassignedCount ?? this.reassignedCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

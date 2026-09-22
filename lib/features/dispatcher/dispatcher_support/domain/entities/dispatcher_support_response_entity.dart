import 'dispatcher_support_issue_entity.dart';
import 'dispatcher_support_kpi_entity.dart';

class DispatcherSupportResponseEntity {
  const DispatcherSupportResponseEntity({
    this.counters = const DispatcherSupportKpiEntity(),
    this.areaChips = const [],
    this.issues = const [],
    this.pagination = const DispatcherSupportPaginationEntity(),
  });

  final DispatcherSupportKpiEntity counters;
  final List<DispatcherSupportAreaChipEntity> areaChips;
  final List<DispatcherSupportIssueEntity> issues;
  final DispatcherSupportPaginationEntity pagination;

  DispatcherSupportResponseEntity copyWith({
    DispatcherSupportKpiEntity? counters,
    List<DispatcherSupportAreaChipEntity>? areaChips,
    List<DispatcherSupportIssueEntity>? issues,
    DispatcherSupportPaginationEntity? pagination,
  }) {
    return DispatcherSupportResponseEntity(
      counters: counters ?? this.counters,
      areaChips: areaChips ?? this.areaChips,
      issues: issues ?? this.issues,
      pagination: pagination ?? this.pagination,
    );
  }
}

class DispatcherSupportAreaChipEntity {
  const DispatcherSupportAreaChipEntity({
    required this.areaKey,
    required this.displayName,
    this.count = 0,
  });

  final String areaKey;
  final String displayName;
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherSupportAreaChipEntity &&
          runtimeType == other.runtimeType &&
          areaKey == other.areaKey &&
          displayName == displayName &&
          count == count;

  @override
  int get hashCode => Object.hash(areaKey, displayName, count);
}

class DispatcherSupportPaginationEntity {
  const DispatcherSupportPaginationEntity({
    this.pageNumber = 1,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherSupportPaginationEntity &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize &&
          totalCount == other.totalCount &&
          totalPages == other.totalPages &&
          hasNextPage == other.hasNextPage &&
          hasPreviousPage == other.hasPreviousPage;

  @override
  int get hashCode => Object.hash(
    pageNumber,
    pageSize,
    totalCount,
    totalPages,
    hasNextPage,
    hasPreviousPage,
  );
}

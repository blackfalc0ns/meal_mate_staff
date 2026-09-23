class OperationsPaginationEntity {
  const OperationsPaginationEntity({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.totalItems = 0,
    this.totalPages = 0,
    this.hasPreviousPage = false,
    this.hasNextPage = false,
  });

  final int pageNumber;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationsPaginationEntity &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize &&
          totalItems == other.totalItems &&
          totalPages == other.totalPages &&
          hasPreviousPage == other.hasPreviousPage &&
          hasNextPage == other.hasNextPage;

  @override
  int get hashCode => Object.hash(
    pageNumber,
    pageSize,
    totalItems,
    totalPages,
    hasPreviousPage,
    hasNextPage,
  );
}

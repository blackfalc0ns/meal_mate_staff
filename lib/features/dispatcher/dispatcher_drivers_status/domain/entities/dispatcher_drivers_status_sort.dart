enum DispatcherDriversStatusSort {
  name,
  ratingDesc,
  newest,
  status;

  String get apiValue {
    switch (this) {
      case DispatcherDriversStatusSort.name:
        return 'Name';
      case DispatcherDriversStatusSort.ratingDesc:
        return 'RatingDesc';
      case DispatcherDriversStatusSort.newest:
        return 'Newest';
      case DispatcherDriversStatusSort.status:
        return 'Status';
    }
  }
}

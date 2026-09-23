class DispatcherDriverDetailsRouteArgs {
  const DispatcherDriverDetailsRouteArgs({required this.driverId});

  final String driverId;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  bool get isValid => _guidRegex.hasMatch(driverId.trim());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverDetailsRouteArgs &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId;

  @override
  int get hashCode => driverId.hashCode;

  @override
  String toString() => 'DispatcherDriverDetailsRouteArgs(driverId: $driverId)';
}

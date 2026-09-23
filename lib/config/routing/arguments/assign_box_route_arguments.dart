class AssignBoxRouteArgs {
  const AssignBoxRouteArgs({required this.boxId});

  final String boxId;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  bool get isValid =>
      boxId.trim().isNotEmpty && _guidRegex.hasMatch(boxId.trim());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignBoxRouteArgs &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId;

  @override
  int get hashCode => boxId.hashCode;
}

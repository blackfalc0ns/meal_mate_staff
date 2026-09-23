class BoxTrackingRouteArguments {
  const BoxTrackingRouteArguments({required this.boxId});

  final String boxId;

  static final RegExp _guidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  bool get isValid => _guidRegex.hasMatch(boxId.trim());
}

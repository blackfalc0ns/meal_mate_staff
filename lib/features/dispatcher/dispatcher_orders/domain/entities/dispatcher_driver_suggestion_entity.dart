enum DispatcherDriverSuggestionType {
  nearest,
  leastLoaded,
  unknown;

  static DispatcherDriverSuggestionType fromWire(String? value) {
    return switch (value?.toLowerCase()) {
      'nearest' => DispatcherDriverSuggestionType.nearest,
      'leastloaded' => DispatcherDriverSuggestionType.leastLoaded,
      _ => DispatcherDriverSuggestionType.unknown,
    };
  }
}

class DispatcherDriverSuggestionEntity {
  const DispatcherDriverSuggestionEntity({
    required this.driverId,
    required this.driverName,
    this.avatarUrl,
    required this.suggestionType,
    required this.label,
  });

  final String driverId;
  final String driverName;
  final String? avatarUrl;
  final DispatcherDriverSuggestionType suggestionType;
  final String label;
}

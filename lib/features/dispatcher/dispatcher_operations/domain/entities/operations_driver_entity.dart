import 'operations_indicator_color.dart';

class OperationsDriverEntity {
  const OperationsDriverEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.indicatorColor = OperationsIndicatorColor.unknown,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final OperationsIndicatorColor indicatorColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationsDriverEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          avatarUrl == other.avatarUrl &&
          indicatorColor == other.indicatorColor;

  @override
  int get hashCode => Object.hash(id, name, avatarUrl, indicatorColor);
}

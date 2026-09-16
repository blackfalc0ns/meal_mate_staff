class DispatcherHomeKpiItemEntity {
  const DispatcherHomeKpiItemEntity({
    required this.id,
    required this.label,
    required this.value,
    required this.iconAsset,
    required this.accentColorType,
  });

  final String id;
  final String label;
  final String value;
  final String iconAsset;
  final DispatcherHomeKpiColorType accentColorType;
}

enum DispatcherHomeKpiColorType {
  purple,
  blue,
  orange,
  red,
}

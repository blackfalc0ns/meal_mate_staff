class OperationsCustomerEntity {
  const OperationsCustomerEntity({
    required this.id,
    required this.name,
    required this.area,
    required this.addressText,
  });

  final String id;
  final String name;
  final String area;
  final String addressText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationsCustomerEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          area == other.area &&
          addressText == other.addressText;

  @override
  int get hashCode => Object.hash(id, name, area, addressText);
}

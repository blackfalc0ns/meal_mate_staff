class AssignBoxMealEntity {
  const AssignBoxMealEntity({
    required this.mealId,
    required this.mealName,
    required this.quantity,
    this.category,
    this.notes,
  });

  final String mealId;
  final String mealName;
  final int quantity;
  final String? category;
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignBoxMealEntity &&
          runtimeType == other.runtimeType &&
          mealId == other.mealId &&
          mealName == other.mealName &&
          quantity == other.quantity &&
          category == other.category &&
          notes == other.notes;

  @override
  int get hashCode =>
      mealId.hashCode ^
      mealName.hashCode ^
      quantity.hashCode ^
      category.hashCode ^
      notes.hashCode;
}

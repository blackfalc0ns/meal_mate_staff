import 'assign_box_meal_entity.dart';

class AssignBoxSummaryEntity {
  const AssignBoxSummaryEntity({
    required this.boxId,
    required this.boxCode,
    this.customerMaskedId,
    this.customerNameMasked,
    this.customerPhoneMasked,
    this.zoneName,
    this.address,
    this.deliveryTimeWindow,
    required this.boxCount,
    this.barcode,
    this.deliveryNotes,
    this.allergies = const [],
    this.meals = const [],
  });

  final String boxId;
  final String boxCode;
  final String? customerMaskedId;
  final String? customerNameMasked;
  final String? customerPhoneMasked;
  final String? zoneName;
  final String? address;
  final String? deliveryTimeWindow;
  final int boxCount;
  final String? barcode;
  final String? deliveryNotes;
  final List<String> allergies;
  final List<AssignBoxMealEntity> meals;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignBoxSummaryEntity &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          boxCode == other.boxCode &&
          customerMaskedId == other.customerMaskedId &&
          customerNameMasked == other.customerNameMasked &&
          customerPhoneMasked == other.customerPhoneMasked &&
          zoneName == other.zoneName &&
          address == other.address &&
          deliveryTimeWindow == other.deliveryTimeWindow &&
          boxCount == other.boxCount &&
          barcode == other.barcode &&
          deliveryNotes == other.deliveryNotes &&
          allergies == other.allergies &&
          meals == other.meals;

  @override
  int get hashCode =>
      boxId.hashCode ^
      boxCode.hashCode ^
      customerMaskedId.hashCode ^
      customerNameMasked.hashCode ^
      customerPhoneMasked.hashCode ^
      zoneName.hashCode ^
      address.hashCode ^
      deliveryTimeWindow.hashCode ^
      boxCount.hashCode ^
      barcode.hashCode ^
      deliveryNotes.hashCode ^
      allergies.hashCode ^
      meals.hashCode;
}

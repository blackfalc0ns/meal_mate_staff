import 'package:json_annotation/json_annotation.dart';

part 'assign_box_summary_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class AssignBoxSummaryResponseDto {
  const AssignBoxSummaryResponseDto({
    this.boxId,
    this.boxCode,
    this.customerMaskedId,
    this.customerNameMasked,
    this.customerPhoneMasked,
    this.zoneName,
    this.address,
    this.deliveryTimeWindow,
    this.boxCount,
    this.barcode,
    this.deliveryNotes,
    this.allergies,
    this.meals,
  });

  factory AssignBoxSummaryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AssignBoxSummaryResponseDtoFromJson(json);

  final String? boxId;
  final String? boxCode;
  final String? customerMaskedId;
  final String? customerNameMasked;
  final String? customerPhoneMasked;
  final String? zoneName;
  final String? address;
  final String? deliveryTimeWindow;
  final int? boxCount;
  final String? barcode;
  final String? deliveryNotes;
  final List<String>? allergies;
  final List<AssignBoxMealDto>? meals;
}

@JsonSerializable(createToJson: false)
class AssignBoxMealDto {
  const AssignBoxMealDto({
    this.mealId,
    this.mealName,
    this.quantity,
    this.category,
    this.notes,
  });

  factory AssignBoxMealDto.fromJson(Map<String, dynamic> json) =>
      _$AssignBoxMealDtoFromJson(json);

  final String? mealId;
  final String? mealName;
  final int? quantity;
  final String? category;
  final String? notes;
}

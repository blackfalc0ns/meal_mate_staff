// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_box_summary_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignBoxSummaryResponseDto _$AssignBoxSummaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => AssignBoxSummaryResponseDto(
  boxId: json['boxId'] as String?,
  boxCode: json['boxCode'] as String?,
  customerMaskedId: json['customerMaskedId'] as String?,
  customerNameMasked: json['customerNameMasked'] as String?,
  customerPhoneMasked: json['customerPhoneMasked'] as String?,
  zoneName: json['zoneName'] as String?,
  address: json['address'] as String?,
  deliveryTimeWindow: json['deliveryTimeWindow'] as String?,
  boxCount: (json['boxCount'] as num?)?.toInt(),
  barcode: json['barcode'] as String?,
  deliveryNotes: json['deliveryNotes'] as String?,
  allergies: (json['allergies'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  meals: (json['meals'] as List<dynamic>?)
      ?.map((e) => AssignBoxMealDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

AssignBoxMealDto _$AssignBoxMealDtoFromJson(Map<String, dynamic> json) =>
    AssignBoxMealDto(
      mealId: json['mealId'] as String?,
      mealName: json['mealName'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
    );

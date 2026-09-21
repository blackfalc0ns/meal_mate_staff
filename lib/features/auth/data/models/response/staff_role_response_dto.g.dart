// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_role_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffRoleResponseDto _$StaffRoleResponseDtoFromJson(
  Map<String, dynamic> json,
) => StaffRoleResponseDto(
  code: json['code'] as String?,
  name: json['name'] as String?,
  nameAr: json['nameAr'] as String?,
  nameEn: json['nameEn'] as String?,
  description: json['description'] as String?,
  descriptionAr: json['descriptionAr'] as String?,
  descriptionEn: json['descriptionEn'] as String?,
  iconKey: json['iconKey'] as String?,
  allowsSelfRegistration: json['allowsSelfRegistration'] as bool?,
  displayOrder: (json['displayOrder'] as num?)?.toInt(),
);

Map<String, dynamic> _$StaffRoleResponseDtoToJson(
  StaffRoleResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'description': instance.description,
  'descriptionAr': instance.descriptionAr,
  'descriptionEn': instance.descriptionEn,
  'iconKey': instance.iconKey,
  'allowsSelfRegistration': instance.allowsSelfRegistration,
  'displayOrder': instance.displayOrder,
};

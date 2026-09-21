import 'package:json_annotation/json_annotation.dart';

part 'staff_role_response_dto.g.dart';

@JsonSerializable()
class StaffRoleResponseDto {
  const StaffRoleResponseDto({
    this.code,
    this.name,
    this.nameAr,
    this.nameEn,
    this.description,
    this.descriptionAr,
    this.descriptionEn,
    this.iconKey,
    this.allowsSelfRegistration,
    this.displayOrder,
  });

  factory StaffRoleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$StaffRoleResponseDtoFromJson(json);

  final String? code;
  final String? name;
  final String? nameAr;
  final String? nameEn;
  final String? description;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? iconKey;
  final bool? allowsSelfRegistration;
  final int? displayOrder;

  Map<String, dynamic> toJson() => _$StaffRoleResponseDtoToJson(this);
}

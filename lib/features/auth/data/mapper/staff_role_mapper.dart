import '../../domain/entities/staff_role_entity.dart';
import '../../domain/user_role.dart';
import '../models/response/staff_role_response_dto.dart';

extension UserRoleApiMapper on UserRole {
  String toApiValue() => apiValue;
}

extension StringToUserRoleMapper on String? {
  UserRole toUserRole() => UserRole.fromApiValue(this);
}

extension StaffRoleResponseDtoMapper on StaffRoleResponseDto {
  StaffRoleEntity toEntity() {
    final rawCode = code?.trim() ?? '';
    final rawName = name?.trim() ?? '';
    final rawNameAr = nameAr?.trim() ?? '';
    final rawNameEn = nameEn?.trim() ?? '';
    final rawDesc = description?.trim() ?? '';
    final rawDescAr = descriptionAr?.trim() ?? '';
    final rawDescEn = descriptionEn?.trim() ?? '';

    return StaffRoleEntity(
      code: rawCode,
      name: rawName.isNotEmpty ? rawName : rawNameEn,
      nameAr: rawNameAr.isNotEmpty ? rawNameAr : rawName,
      nameEn: rawNameEn.isNotEmpty
          ? rawNameEn
          : (rawName.isNotEmpty ? rawName : rawCode),
      description: rawDesc.isNotEmpty ? rawDesc : rawDescEn,
      descriptionAr: rawDescAr.isNotEmpty ? rawDescAr : rawDesc,
      descriptionEn: rawDescEn.isNotEmpty ? rawDescEn : rawDesc,
      iconKey: iconKey?.trim() ?? '',
      allowsSelfRegistration: allowsSelfRegistration ?? false,
      displayOrder: displayOrder ?? 0,
    );
  }
}

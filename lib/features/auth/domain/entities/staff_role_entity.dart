import '../user_role.dart';

class StaffRoleEntity {
  const StaffRoleEntity({
    required this.code,
    required this.name,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.iconKey,
    required this.allowsSelfRegistration,
    required this.displayOrder,
  });

  final String code;
  final String name;
  final String nameAr;
  final String nameEn;
  final String description;
  final String descriptionAr;
  final String descriptionEn;
  final String iconKey;
  final bool allowsSelfRegistration;
  final int displayOrder;

  UserRole get userRole => UserRole.fromApiValue(code);

  String localizedName(bool isArabic) {
    if (isArabic && nameAr.trim().isNotEmpty) return nameAr.trim();
    if (!isArabic && nameEn.trim().isNotEmpty) return nameEn.trim();
    return name.trim();
  }

  String localizedDescription(bool isArabic) {
    if (isArabic && descriptionAr.trim().isNotEmpty) {
      return descriptionAr.trim();
    }
    if (!isArabic && descriptionEn.trim().isNotEmpty) {
      return descriptionEn.trim();
    }
    return description.trim();
  }
}

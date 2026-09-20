import '../../domain/user_role.dart';

extension UserRoleApiMapper on UserRole {
  String toApiValue() => apiValue;
}

extension StringToUserRoleMapper on String? {
  UserRole toUserRole() => UserRole.fromApiValue(this);
}

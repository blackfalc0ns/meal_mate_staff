class DispatcherProfileEntity {
  const DispatcherProfileEntity({
    required this.name,
    required this.roleTitle,
    required this.roleCode,
    required this.isAvailable,
    required this.avatarAsset,
    required this.phone,
    required this.email,
    required this.isEmailEditable,
    required this.maskedPassword,
  });

  final String name;
  final String roleTitle;
  final String roleCode;
  final bool isAvailable;
  final String avatarAsset;
  final String phone;
  final String email;
  final bool isEmailEditable;
  final String maskedPassword;
}

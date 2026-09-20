import '../../../../features/auth/domain/user_role.dart';

/// Entity representing the user and status shown in the sidebar header and status card.
class SidebarUserEntity {
  const SidebarUserEntity({
    required this.name,
    this.avatarAsset = 'assets/images/driver/driver_avatar.png',
    this.isOnline = true,
    this.role = UserRole.operations,
    this.statusTitle = '',
    this.statusText = '',
    this.statusSubtitle = '',
    this.appVersion = '2.4.1',
  });

  final String name;
  final String avatarAsset;
  final bool isOnline;
  final UserRole role;
  final String statusTitle;
  final String statusText;
  final String statusSubtitle;
  final String appVersion;

  SidebarUserEntity copyWith({
    String? name,
    String? avatarAsset,
    bool? isOnline,
    UserRole? role,
    String? statusTitle,
    String? statusText,
    String? statusSubtitle,
    String? appVersion,
  }) {
    return SidebarUserEntity(
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      isOnline: isOnline ?? this.isOnline,
      role: role ?? this.role,
      statusTitle: statusTitle ?? this.statusTitle,
      statusText: statusText ?? this.statusText,
      statusSubtitle: statusSubtitle ?? this.statusSubtitle,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

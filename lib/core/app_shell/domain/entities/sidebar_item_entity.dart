import 'package:flutter/widgets.dart';

/// Entity representing an item in the navigation sidebar.
class SidebarItemEntity {
  const SidebarItemEntity({
    required this.id,
    required this.title,
    this.iconData,
    this.iconAsset,
    this.badgeCount,
    this.isSelected = false,
    this.onTap,
  });

  final String id;
  final String title;
  final IconData? iconData;
  final String? iconAsset;
  final int? badgeCount;
  final bool isSelected;
  final VoidCallback? onTap;

  SidebarItemEntity copyWith({
    String? id,
    String? title,
    IconData? iconData,
    String? iconAsset,
    int? badgeCount,
    bool? isSelected,
    VoidCallback? onTap,
  }) {
    return SidebarItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      iconData: iconData ?? this.iconData,
      iconAsset: iconAsset ?? this.iconAsset,
      badgeCount: badgeCount ?? this.badgeCount,
      isSelected: isSelected ?? this.isSelected,
      onTap: onTap ?? this.onTap,
    );
  }
}

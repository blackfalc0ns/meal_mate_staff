import 'package:flutter/material.dart';

import '../../../../features/auth/domain/user_role.dart';
import '../entities/sidebar_item_entity.dart';
import '../entities/sidebar_user_entity.dart';

/// Fake data provider for the shared navigation sidebar.
class SidebarFakeData {
  const SidebarFakeData._();

  static SidebarUserEntity getDefaultUser(UserRole role) {
    if (role == UserRole.driver) {
      return const SidebarUserEntity(
        name: 'محمد علي',
        avatarAsset: 'assets/images/driver/driver_avatar.png',
        isOnline: true,
        role: UserRole.driver,
        statusTitle: 'حالة السائق',
        statusText: 'خارج التوصيل',
        statusSubtitle: 'متاح لتوصيل الطلبات',
        appVersion: '2.4.1',
      );
    }
    return const SidebarUserEntity(
      name: 'عبدالله خالد',
      avatarAsset: 'assets/images/driver/driver_avatar.png',
      isOnline: true,
      role: UserRole.operations,
      statusTitle: 'حالة الموزع',
      statusText: 'في الخدمة',
      statusSubtitle: 'متاح لإدارة العمليات',
      appVersion: '2.4.1',
    );
  }

  static List<SidebarItemEntity> getDefaultItems({
    required UserRole role,
    String activeId = 'home',
  }) {
    if (role == UserRole.driver) {
      return [
        SidebarItemEntity(
          id: 'home',
          title: 'الرئيسية',
          iconData: Icons.home_rounded,
          isSelected: activeId == 'home',
        ),
        SidebarItemEntity(
          id: 'orders',
          title: 'الطلبات',
          iconData: Icons.inventory_2_rounded,
          isSelected: activeId == 'orders',
        ),
        SidebarItemEntity(
          id: 'map',
          title: 'الخريطة',
          iconData: Icons.map_rounded,
          isSelected: activeId == 'map',
        ),
        SidebarItemEntity(
          id: 'analytics',
          title: 'الإحصائيات',
          iconData: Icons.bar_chart_rounded,
          isSelected: activeId == 'analytics',
        ),
        SidebarItemEntity(
          id: 'operations_log',
          title: 'سجل العمليات',
          iconData: Icons.receipt_long_rounded,
          isSelected: activeId == 'operations_log',
        ),
        SidebarItemEntity(
          id: 'notifications',
          title: 'الإشعارات',
          iconData: Icons.notifications_rounded,
          badgeCount: 3,
          isSelected: activeId == 'notifications',
        ),
        SidebarItemEntity(
          id: 'support',
          title: 'المساعدة والدعم',
          iconData: Icons.help_rounded,
          isSelected: activeId == 'support',
        ),
        SidebarItemEntity(
          id: 'settings',
          title: 'الإعدادات',
          iconData: Icons.settings_rounded,
          isSelected: activeId == 'settings',
        ),
        SidebarItemEntity(
          id: 'safety',
          title: 'السلامة والأمان',
          iconData: Icons.shield_rounded,
          isSelected: activeId == 'safety',
        ),
      ];
    }

    return [
      SidebarItemEntity(
        id: 'home',
        title: 'الرئيسية',
        iconData: Icons.home_rounded,
        isSelected: activeId == 'home',
      ),
      SidebarItemEntity(
        id: 'orders',
        title: 'الطلبات',
        iconData: Icons.inventory_2_rounded,
        isSelected: activeId == 'orders',
      ),
      SidebarItemEntity(
        id: 'map',
        title: 'الخريطة',
        iconData: Icons.map_rounded,
        isSelected: activeId == 'map',
      ),
      SidebarItemEntity(
        id: 'operations_log',
        title: 'سجل العمليات',
        iconData: Icons.receipt_long_rounded,
        isSelected: activeId == 'operations_log',
      ),
      SidebarItemEntity(
        id: 'notifications',
        title: 'الإشعارات',
        iconData: Icons.notifications_rounded,
        isSelected: activeId == 'notifications',
      ),
      SidebarItemEntity(
        id: 'support',
        title: 'المساعدة والدعم',
        iconData: Icons.help_rounded,
        isSelected: activeId == 'support',
      ),
      SidebarItemEntity(
        id: 'settings',
        title: 'الإعدادات',
        iconData: Icons.settings_rounded,
        isSelected: activeId == 'settings',
      ),
    ];
  }
}

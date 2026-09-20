import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/app_shell/domain/entities/sidebar_item_entity.dart';
import 'package:meal_mate_delivery/core/app_shell/domain/entities/sidebar_user_entity.dart';
import 'package:meal_mate_delivery/core/app_shell/domain/fake_data/sidebar_fake_data.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

void main() {
  group('Sidebar Domain Entities', () {
    test('SidebarItemEntity holds expected values', () {
      bool tapped = false;
      final item = SidebarItemEntity(
        id: 'orders',
        title: 'الطلبات',
        iconData: Icons.inventory_2_rounded,
        badgeCount: 3,
        isSelected: true,
        onTap: () => tapped = true,
      );

      expect(item.id, 'orders');
      expect(item.title, 'الطلبات');
      expect(item.iconData, Icons.inventory_2_rounded);
      expect(item.badgeCount, 3);
      expect(item.isSelected, true);
      item.onTap?.call();
      expect(tapped, true);
    });

    test('SidebarUserEntity holds expected values', () {
      const user = SidebarUserEntity(
        name: 'محمد علي',
        avatarAsset: 'assets/images/driver/driver_avatar.png',
        isOnline: true,
        role: UserRole.driver,
        statusTitle: 'حالة السائق',
        statusText: 'خارج التوصيل',
        statusSubtitle: 'متاح لتوصيل الطلبات',
        appVersion: '2.4.1',
      );

      expect(user.name, 'محمد علي');
      expect(user.avatarAsset, 'assets/images/driver/driver_avatar.png');
      expect(user.isOnline, true);
      expect(user.role, UserRole.driver);
      expect(user.statusTitle, 'حالة السائق');
      expect(user.statusText, 'خارج التوصيل');
      expect(user.statusSubtitle, 'متاح لتوصيل الطلبات');
      expect(user.appVersion, '2.4.1');
    });

    test('SidebarFakeData provides default user for driver and dispatcher', () {
      final driver = SidebarFakeData.getDefaultUser(UserRole.driver);
      expect(driver.role, UserRole.driver);
      expect(driver.name, isNotEmpty);
      expect(driver.isOnline, true);

      final dispatcher = SidebarFakeData.getDefaultUser(UserRole.operations);
      expect(dispatcher.role, UserRole.operations);
      expect(dispatcher.name, isNotEmpty);
    });

    test('SidebarFakeData provides default items for driver (9 items)', () {
      final items = SidebarFakeData.getDefaultItems(
        role: UserRole.driver,
        activeId: 'home',
      );

      expect(items.length, 9);
      expect(items.first.id, 'home');
      expect(items.first.isSelected, true);
      expect(items[1].isSelected, false);
      expect(items.any((i) => i.id == 'notifications' && i.badgeCount == 3), true);
    });

    test('SidebarFakeData provides default items for dispatcher', () {
      final items = SidebarFakeData.getDefaultItems(
        role: UserRole.operations,
        activeId: 'orders',
      );

      expect(items.isNotEmpty, true);
      expect(items.firstWhere((i) => i.id == 'orders').isSelected, true);
    });
  });
}

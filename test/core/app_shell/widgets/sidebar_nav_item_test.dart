import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/app_shell/domain/entities/sidebar_item_entity.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_nav_item_tile.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_nav_list.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';

Widget _buildTestApp(Widget child, {Locale locale = const Locale('ar')}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Sidebar Navigation Widgets', () {
    testWidgets('SidebarNavItemTile renders active state with start indicator',
        (tester) async {
      bool tapped = false;
      final activeItem = SidebarItemEntity(
        id: 'home',
        title: 'الرئيسية',
        iconData: Icons.home_rounded,
        isSelected: true,
      );

      await tester.pumpWidget(_buildTestApp(
        SidebarNavItemTile(
          item: activeItem,
          onTap: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);

      await tester.tap(find.text('الرئيسية'));
      expect(tapped, true);
    });

    testWidgets('SidebarNavItemTile renders inactive state with badge and chevron',
        (tester) async {
      final inactiveItem = SidebarItemEntity(
        id: 'notifications',
        title: 'الإشعارات',
        iconData: Icons.notifications_rounded,
        badgeCount: 3,
        isSelected: false,
      );

      await tester.pumpWidget(_buildTestApp(
        SidebarNavItemTile(item: inactiveItem),
      ));
      await tester.pumpAndSettle();

      expect(find.text('الإشعارات'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('SidebarNavList renders items with dividers', (tester) async {
      SidebarItemEntity? selectedItem;
      final items = [
        const SidebarItemEntity(
          id: 'home',
          title: 'الرئيسية',
          iconData: Icons.home_rounded,
          isSelected: true,
        ),
        const SidebarItemEntity(
          id: 'orders',
          title: 'الطلبات',
          iconData: Icons.inventory_2_rounded,
        ),
      ];

      await tester.pumpWidget(_buildTestApp(
        SidebarNavList(
          items: items,
          onItemTap: (item) => selectedItem = item,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);

      await tester.tap(find.text('الطلبات'));
      expect(selectedItem?.id, 'orders');
    });
  });
}

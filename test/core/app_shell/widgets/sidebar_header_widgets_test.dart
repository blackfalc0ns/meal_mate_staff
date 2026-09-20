import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/app_shell/domain/entities/sidebar_user_entity.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_notification_badge.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_user_header.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_user_status_chip.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_version_footer.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar'),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Sidebar Header & Atomic Widgets', () {
    testWidgets('SidebarUserStatusChip renders online indicator and text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const SidebarUserStatusChip(isOnline: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('متصل'), findsOneWidget);
    });

    testWidgets('SidebarUserHeader renders user name and avatar', (
      tester,
    ) async {
      const user = SidebarUserEntity(name: 'محمد علي', isOnline: true);

      await tester.pumpWidget(
        _buildTestApp(const SidebarUserHeader(user: user)),
      );
      await tester.pumpAndSettle();

      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.text('متصل'), findsOneWidget);
    });

    testWidgets('SidebarNotificationBadge renders badge count', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const SidebarNotificationBadge(count: 3)),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('SidebarVersionFooter renders localized version text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(const SidebarVersionFooter(version: '2.4.1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('الإصدار 2.4.1'), findsOneWidget);
    });
  });
}

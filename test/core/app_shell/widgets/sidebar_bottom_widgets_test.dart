import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/app_shell/domain/entities/sidebar_user_entity.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_driver_status_card.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/sidebar_logout_button.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

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
  group('Sidebar Bottom Widgets', () {
    testWidgets('SidebarDriverStatusCard renders driver status info',
        (tester) async {
      const user = SidebarUserEntity(
        name: 'محمد علي',
        role: UserRole.driver,
        statusTitle: 'حالة السائق',
        statusText: 'خارج التوصيل',
        statusSubtitle: 'متاح لتوصيل الطلبات',
      );

      await tester.pumpWidget(_buildTestApp(
        const SidebarDriverStatusCard(user: user),
      ));
      await tester.pumpAndSettle();

      expect(find.text('حالة السائق'), findsOneWidget);
      expect(find.text('خارج التوصيل'), findsOneWidget);
      expect(find.text('متاح لتوصيل الطلبات'), findsOneWidget);
    });

    testWidgets('SidebarLogoutButton triggers callback on tap', (tester) async {
      bool logoutTapped = false;

      await tester.pumpWidget(_buildTestApp(
        SidebarLogoutButton(onLogout: () => logoutTapped = true),
      ));
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الخروج'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

      await tester.tap(find.text('تسجيل الخروج'));
      expect(logoutTapped, true);
    });
  });
}

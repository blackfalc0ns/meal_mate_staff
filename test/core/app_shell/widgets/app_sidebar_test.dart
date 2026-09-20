import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/sidebar/app_sidebar.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

Widget _buildTestApp({
  UserRole role = UserRole.driver,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar'),
    home: AppShellScreen(role: role),
  );
}

void main() {
  group('AppSidebar Widget & Shell Integration', () {
    testWidgets('AppSidebar renders correctly for Driver role', (tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          key: scaffoldKey,
          drawer: const AppSidebar(role: UserRole.driver),
          body: const SizedBox(),
        ),
      ));
      await tester.pumpAndSettle();

      // Open drawer
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.text('متصل'), findsOneWidget);

      // Verify items
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('الإحصائيات'), findsOneWidget);
      expect(find.text('السلامة والأمان'), findsOneWidget);

      // Verify driver status card
      expect(find.text('حالة السائق'), findsOneWidget);
      expect(find.text('خارج التوصيل'), findsOneWidget);

      // Verify logout button and footer
      expect(find.text('تسجيل الخروج'), findsOneWidget);
      expect(find.text('الإصدار 2.4.1'), findsOneWidget);
    });

    testWidgets('AppSidebar renders correctly for Operations role (omits driver status card)',
        (tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          key: scaffoldKey,
          drawer: const AppSidebar(role: UserRole.operations),
          body: const SizedBox(),
        ),
      ));
      await tester.pumpAndSettle();

      // Open drawer
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      // Verify dispatcher name and header
      expect(find.text('عبدالله خالد'), findsOneWidget);
      expect(find.text('متصل'), findsOneWidget);

      // Verify items
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('سجل العمليات'), findsOneWidget);

      // Driver status card should NOT be present for operations role
      expect(find.text('حالة السائق'), findsNothing);
    });

    testWidgets('AppShellScreen integrates AppSidebar as drawer',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(role: UserRole.driver));
      await tester.pumpAndSettle();

      // Find Scaffold and open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.byType(AppSidebar), findsOneWidget);
      expect(find.text('محمد علي'), findsOneWidget);

      // Tap an item in sidebar to navigate/close drawer
      await tester.tap(find.descendant(
        of: find.byType(AppSidebar),
        matching: find.text('الطلبات'),
      ));
      await tester.pumpAndSettle();

      // Drawer should be closed
      expect(scaffoldState.isDrawerOpen, false);
    });
  });
}

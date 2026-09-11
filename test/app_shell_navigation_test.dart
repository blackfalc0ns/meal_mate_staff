import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/app_bottom_nav_bar.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/app_bottom_nav_item.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/meal_mate_nav_logo.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    int selectedIndex = 0,
    ValueChanged<int>? onItemSelected,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: const SizedBox(),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: selectedIndex,
          onItemSelected: onItemSelected,
        ),
      ),
    );
  }

  Widget buildAppShellSubject({
    Locale locale = const Locale('ar'),
    int initialIndex = 0,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: AppShellScreen(
        initialIndex: initialIndex,
        pages: const [
          Text('Page Home'),
          Text('Page Orders'),
          Text('Page Delivery'),
          Text('Page Support'),
          Text('Page Account'),
        ],
      ),
    );
  }

  group('AppBottomNavBar Widget Tests', () {
    testWidgets('renders all 5 tabs in Arabic locale', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(find.byType(AppBottomNavItem), findsNWidgets(5));
      expect(find.byType(MealMateNavLogo), findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(5));

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('الدعم'), findsOneWidget);
      expect(find.text('الحساب'), findsOneWidget);
    });

    testWidgets('renders all 5 tabs in English locale', (tester) async {
      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('triggers onItemSelected when tab is tapped', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildSubject(onItemSelected: (index) => selected = index),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('الطلبات'));
      expect(selected, 1);

      await tester.tap(find.text('الخريطة'));
      expect(selected, 2);

      await tester.tap(find.text('الدعم'));
      expect(selected, 3);

      await tester.tap(find.text('الحساب'));
      expect(selected, 4);

      await tester.tap(find.text('الرئيسية'));
      expect(selected, 0);
    });
  });

  group('AppShellScreen Widget Tests', () {
    testWidgets('switches active page when tab is tapped', (tester) async {
      await tester.pumpWidget(buildAppShellSubject());
      await tester.pumpAndSettle();

      expect(find.text('Page Home'), findsOneWidget);

      await tester.tap(find.text('الطلبات'));
      await tester.pumpAndSettle();

      expect(find.text('Page Orders'), findsOneWidget);

      await tester.tap(find.text('الخريطة'));
      await tester.pumpAndSettle();

      expect(find.text('Page Delivery'), findsOneWidget);
    });
  });
}

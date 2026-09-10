import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/profile/domain/fake_data/dispatcher_profile_fake_data.dart';
import 'package:meal_mate_delivery/features/dispatcher/profile/presentation/screens/dispatcher_profile_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/profile/presentation/widgets/dispatcher_profile_admin_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/profile/presentation/widgets/dispatcher_profile_app_info_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/profile/presentation/widgets/dispatcher_profile_logout_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/profile/presentation/widgets/dispatcher_profile_notification_settings_card.dart';

Widget _buildTestableWidget({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6744C2)),
    ),
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DispatcherProfileScreen Tests', () {
    testWidgets('renders all major components and cards in RTL', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherProfileScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherProfileScreen), findsOneWidget);
      expect(find.byType(DispatcherProfileAdminCard), findsOneWidget);
      expect(
        find.byType(DispatcherProfileNotificationSettingsCard),
        findsOneWidget,
      );
      expect(find.byType(DispatcherProfileAppInfoCard), findsOneWidget);
      expect(find.byType(DispatcherProfileLogoutButton), findsOneWidget);

      // Verify admin details
      expect(
        find.text(DispatcherProfileFakeData.sampleProfile.name),
        findsOneWidget,
      );
      expect(
        find.text(DispatcherProfileFakeData.sampleProfile.roleCode),
        findsOneWidget,
      );
      expect(
        find.text(DispatcherProfileFakeData.sampleProfile.roleTitle),
        findsOneWidget,
      );
      expect(
        find.text(DispatcherProfileFakeData.sampleProfile.phone),
        findsOneWidget,
      );

      // Verify app version
      expect(find.text(DispatcherProfileFakeData.appVersion), findsOneWidget);
    });

    testWidgets('renders properly in LTR English without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DispatcherProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherProfileScreen), findsOneWidget);
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Officer Information'), findsOneWidget);
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Application Info'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('interactive switches toggle notification state', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherProfileScreen()),
      );
      await tester.pumpAndSettle();

      final switchFinders = find.byType(Switch);
      expect(switchFinders, findsNWidgets(4));

      // Toggle first switch
      await tester.tap(switchFinders.first);
      await tester.pumpAndSettle();
    });

    testWidgets('tapping logout button shows confirmation dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 870 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherProfileScreen()),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(DispatcherProfileLogoutButton),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DispatcherProfileLogoutButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}

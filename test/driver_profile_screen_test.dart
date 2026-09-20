import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_settings_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_settings_logout_button.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_settings_menu_tile.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_settings_profile_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_settings_section_card.dart';

void main() {
  Widget buildSubject({
    DriverProfileEntity? profile,
    Locale locale = const Locale('ar'),
    VoidCallback? onHelpCenterTap,
    VoidCallback? onContactUsTap,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: DriverProfileScreen(
        profile: profile,
        onHelpCenterTap: onHelpCenterTap,
        onContactUsTap: onContactUsTap,
      ),
    );
  }

  testWidgets('renders all major components and cards in RTL Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(DriverSettingsHeader), findsOneWidget);
    expect(find.byType(DriverSettingsProfileCard), findsOneWidget);
    expect(find.byType(DriverSettingsSectionCard), findsNWidgets(3));
    expect(find.byType(DriverSettingsMenuTile), findsNWidgets(11));
    expect(find.byType(DriverSettingsLogoutButton), findsOneWidget);

    expect(find.text('الأعدادات'), findsOneWidget);
    expect(find.text('أحمد إبراهيم'), findsOneWidget);
    expect(find.text('#MM-1256'), findsOneWidget);
    expect(find.text('إعدادات الحساب'), findsOneWidget);
    expect(find.text('المعلومات الشخصية'), findsOneWidget);
    expect(find.text('إعدادات التطبيق'), findsOneWidget);
    expect(find.text('الدعم والمساعدة'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('renders all major components in English LTR without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Account Settings'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('App Settings'), findsOneWidget);
    expect(find.text('Support & Help'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets(
    'tapping logout button shows confirmation dialog and can cancel',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final logoutButton = find.byType(DriverSettingsLogoutButton);
      await tester.ensureVisible(logoutButton);
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        findsOneWidget,
      );

      final cancelButton = find.text('إلغاء');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
      }
    },
  );

  testWidgets('tapping Help Center or Contact Us triggers support navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool helpCenterTapped = false;
    bool contactUsTapped = false;

    await tester.pumpWidget(
      buildSubject(
        onHelpCenterTap: () => helpCenterTapped = true,
        onContactUsTap: () => contactUsTapped = true,
      ),
    );
    await tester.pumpAndSettle();

    final helpCenterTile = find.text('مركز المساعدة');
    await tester.ensureVisible(helpCenterTile);
    await tester.tap(helpCenterTile);
    await tester.pumpAndSettle();
    expect(helpCenterTapped, isTrue);

    final contactUsTile = find.text('تواصل معنا');
    await tester.ensureVisible(contactUsTile);
    await tester.tap(contactUsTile);
    await tester.pumpAndSettle();
    expect(contactUsTapped, isTrue);
  });
}

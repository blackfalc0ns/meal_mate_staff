import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_contact_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_hero_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_policy_banner.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_quick_actions_row.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_ticket_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_vehicle_card.dart';

void main() {
  Widget buildSubject({
    DriverProfileEntity? profile,
    Locale locale = const Locale('ar'),
    VoidCallback? onSettingsTap,
    VoidCallback? onContactUsTap,
    VoidCallback? onViewAllTicketsTap,
    VoidCallback? onRecentTicketTap,
    VoidCallback? onLogoutTap,
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
        onSettingsTap: onSettingsTap,
        onContactUsTap: onContactUsTap,
        onViewAllTicketsTap: onViewAllTicketsTap,
        onRecentTicketTap: onRecentTicketTap,
        onLogoutTap: onLogoutTap,
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

    expect(find.byType(DriverProfileHeader), findsOneWidget);
    expect(find.byType(DriverProfileHeroCard), findsOneWidget);
    expect(find.byType(DriverProfileVehicleCard), findsOneWidget);
    expect(find.byType(DriverProfileContactCard), findsOneWidget);
    expect(find.byType(DriverProfileTicketCard), findsOneWidget);
    expect(find.byType(DriverProfileQuickActionsRow), findsOneWidget);
    expect(find.byType(DriverProfilePolicyBanner), findsOneWidget);

    expect(find.text('الملف الشخصي والدعم'), findsOneWidget);
    expect(find.text('أحمد إبراهيم'), findsOneWidget);
    expect(find.text('#MM-1256'), findsOneWidget);
    expect(find.text('معلومات المركبة'), findsOneWidget);
    expect(find.text('نشطة'), findsOneWidget);
    expect(find.text('تواصل مع الدعم'), findsOneWidget);
    expect(find.text('حالة طلب الدعم الأخير'), findsOneWidget);
    expect(find.text('عرض الكل'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
    expect(find.text('سياسة التسليم'), findsOneWidget);
  });

  testWidgets('renders all major components in English LTR without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Profile & Support'), findsOneWidget);
    expect(find.text('Vehicle Information'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.text('Recent Support Request Status'), findsOneWidget);
    expect(find.text('View All'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Delivery Policy'), findsOneWidget);
  });

  testWidgets('tapping Settings triggers onSettingsTap callback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool settingsTapped = false;
    await tester.pumpWidget(
      buildSubject(onSettingsTap: () => settingsTapped = true),
    );
    await tester.pumpAndSettle();

    final settingsCard = find.text('الإعدادات');
    await tester.ensureVisible(settingsCard);
    await tester.tap(settingsCard);
    await tester.pumpAndSettle();

    expect(settingsTapped, isTrue);
  });

  testWidgets('tapping Contact Us and View All triggers callbacks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool contactTapped = false;
    bool viewAllTapped = false;
    await tester.pumpWidget(
      buildSubject(
        onContactUsTap: () => contactTapped = true,
        onViewAllTicketsTap: () => viewAllTapped = true,
      ),
    );
    await tester.pumpAndSettle();

    final contactCard = find.text('تواصل مع الدعم');
    await tester.ensureVisible(contactCard);
    await tester.tap(contactCard);
    await tester.pumpAndSettle();
    expect(contactTapped, isTrue);

    final viewAllBtn = find.text('عرض الكل');
    await tester.ensureVisible(viewAllBtn);
    await tester.tap(viewAllBtn);
    await tester.pumpAndSettle();
    expect(viewAllTapped, isTrue);
  });

  testWidgets('tapping Logout triggers custom callback when provided', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool logoutTapped = false;
    await tester.pumpWidget(
      buildSubject(onLogoutTap: () => logoutTapped = true),
    );
    await tester.pumpAndSettle();

    final logoutCard = find.text('تسجيل الخروج');
    await tester.ensureVisible(logoutCard);
    await tester.tap(logoutCard);
    await tester.pumpAndSettle();

    expect(logoutTapped, isTrue);
  });
}

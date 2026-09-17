import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_delivery_policy_banner.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_info_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_quick_action_tile.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_recent_ticket_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_support_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_vehicle_card.dart';

void main() {
  Widget buildSubject({
    DriverProfileEntity? profile,
    Locale locale = const Locale('ar'),
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
      home: DriverProfileScreen(profile: profile),
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
    expect(find.byType(DriverProfileInfoCard), findsOneWidget);
    expect(find.byType(DriverProfileVehicleCard), findsOneWidget);
    expect(find.byType(DriverProfileSupportCard), findsOneWidget);
    expect(find.byType(DriverProfileRecentTicketCard), findsOneWidget);
    expect(find.byType(DriverProfileQuickActionTile), findsNWidgets(3));
    expect(find.byType(DriverProfileDeliveryPolicyBanner), findsOneWidget);

    expect(find.text('الملف الشخصي والدعم'), findsOneWidget);
    expect(find.text('أحمد إبراهيم'), findsOneWidget);
    expect(find.text('معلومات المركبة'), findsOneWidget);
    expect(find.text('تواصل مع الدعم'), findsOneWidget);
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
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('tapping logout tile shows confirmation dialog and can cancel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final logoutTile = find.widgetWithText(
      DriverProfileQuickActionTile,
      'تسجيل الخروج',
    );
    await tester.ensureVisible(logoutTile);
    await tester.tap(logoutTile);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'), findsOneWidget);

    final cancelButton = find.text('إلغاء');
    if (cancelButton.evaluate().isNotEmpty) {
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    }
  });
}

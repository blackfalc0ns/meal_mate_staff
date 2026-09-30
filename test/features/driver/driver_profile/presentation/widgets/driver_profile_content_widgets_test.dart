import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_ticket_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_vehicle_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_hero_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_ticket_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_profile_vehicle_card.dart';

Widget testApp(Widget child, [Locale locale = const Locale('ar')]) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  const baseProfile = DriverProfileEntity(
    driverProfileId: 'drv-1',
    fullName: 'أحمد إبراهيم',
    driverDescription: 'سائق معتمد',
    driverCode: 'DRV01',
    isOnline: true,
    status: 'Online',
    statusText: 'متصل',
    reviewsCount: 0,
    totalOrders: 0,
  );

  group('DriverProfileHeroCard', () {
    testWidgets(
        'zero reviews and orders display, null rating does not become 0.0',
        (tester) async {
      await tester.pumpWidget(
        testApp(
          DriverProfileHeroCard(
            profile: baseProfile.copyWith(
              averageRating: null,
              reviewsCount: 0,
              totalOrders: 0,
              acceptanceRatePercent: null,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsWidgets);
      expect(find.text('0.0'), findsNothing);
      expect(find.text('0%'), findsNothing);
    });

    testWidgets('displays actual rating and acceptance rate when provided',
        (tester) async {
      await tester.pumpWidget(
        testApp(
          DriverProfileHeroCard(
            profile: baseProfile.copyWith(
              averageRating: 4.8,
              reviewsCount: 25,
              totalOrders: 100,
              acceptanceRatePercent: 95.0,
            ),
          ),
        ),
      );

      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('(25 تقييم)'), findsOneWidget);
    });
  });

  group('DriverProfileVehicleCard', () {
    testWidgets('renders empty state when vehicle is null', (tester) async {
      await tester.pumpWidget(
        testApp(const DriverProfileVehicleCard(vehicle: null)),
      );

      expect(
        find.byKey(const Key('driver_profile_vehicle_empty')),
        findsOneWidget,
      );
    });

    testWidgets('renders vehicle info, color, and plate governorate',
        (tester) async {
      const vehicle = DriverProfileVehicleEntity(
        vehicleType: 'سيارة',
        vehicleModel: 'تويوتا كورولا',
        vehicleYear: 2022,
        color: 'أبيض',
        plateNumber: '123 أ ب ج',
        plateGovernorate: 'القاهرة',
        verificationStatus: 'Verified',
        verificationStatusText: 'موثقة',
        isVehicleActive: true,
      );

      await tester.pumpWidget(
        testApp(const DriverProfileVehicleCard(vehicle: vehicle)),
      );

      expect(find.textContaining('تويوتا كورولا'), findsOneWidget);
      expect(find.textContaining('2022'), findsOneWidget);
      expect(find.text('123 أ ب ج'), findsOneWidget);
      expect(find.textContaining('أبيض'), findsOneWidget);
      expect(find.textContaining('القاهرة'), findsOneWidget);
      expect(find.text('موثقة'), findsOneWidget);
    });
  });

  group('DriverProfileTicketCard', () {
    testWidgets('missing latest ticket does not render fake ticket content',
        (tester) async {
      await tester.pumpWidget(
        testApp(const DriverProfileTicketCard(ticket: null)),
      );

      expect(
        find.byKey(const Key('driver_profile_ticket_empty')),
        findsOneWidget,
      );
      expect(find.text('#SUP-4587'), findsNothing);
    });

    testWidgets('renders real ticket details when ticket is present',
        (tester) async {
      final ticket = DriverProfileTicketEntity(
        ticketId: 't-99',
        ticketNumber: '#TICK-99',
        subject: 'عطل مفاجئ أثناء التوصيل',
        body: 'السيارة بها عطل بالبطارية',
        status: 'Open',
        statusText: 'مفتوحة',
        priority: 'High',
        priorityText: 'عالية',
        createdAtUtc: DateTime.utc(2026, 3, 15),
      );

      await tester.pumpWidget(
        testApp(DriverProfileTicketCard(ticket: ticket)),
      );

      expect(find.text('#TICK-99'), findsOneWidget);
      expect(find.text('عطل مفاجئ أثناء التوصيل'), findsOneWidget);
      expect(find.text('السيارة بها عطل بالبطارية'), findsOneWidget);
      expect(find.text('مفتوحة'), findsOneWidget);
      expect(find.text('عالية'), findsOneWidget);
    });
  });
}

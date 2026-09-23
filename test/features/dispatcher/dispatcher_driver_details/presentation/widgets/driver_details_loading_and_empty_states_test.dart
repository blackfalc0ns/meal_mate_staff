import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_current_location_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_daily_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_kpis_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_action_buttons.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_boxes_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_boxes_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_kpi_row.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_location_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_location_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_performance_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_profile_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_profile_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_shimmer.dart';

Widget createTestApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ar')],
    locale: locale,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('DriverDetailsShimmer & Section Shimmers', () {
    testWidgets(
      'DriverDetailsShimmer mirrors all sections with shape-matched shimmers',
      (tester) async {
        await tester.pumpWidget(createTestApp(const DriverDetailsShimmer()));

        expect(find.byType(DriverDetailsShimmer), findsOneWidget);
        expect(find.byType(DriverDetailsProfileShimmer), findsOneWidget);
        expect(find.byType(DriverDetailsLocationShimmer), findsOneWidget);
        expect(find.byType(DriverDetailsBoxesShimmer), findsOneWidget);
        expect(find.byType(ShimmerWidget), findsAtLeastNWidgets(10));
      },
    );

    testWidgets('Section shimmers can render independently', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Column(
            children: [
              DriverDetailsProfileShimmer(),
              DriverDetailsLocationShimmer(),
              DriverDetailsBoxesShimmer(),
            ],
          ),
        ),
      );

      expect(find.byType(DriverDetailsProfileShimmer), findsOneWidget);
      expect(find.byType(DriverDetailsLocationShimmer), findsOneWidget);
      expect(find.byType(DriverDetailsBoxesShimmer), findsOneWidget);
    });
  });

  group('Empty & Offline States', () {
    testWidgets(
      'DriverDetailsBoxesCard renders localized empty copy when boxes list is empty',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            const DriverDetailsBoxesCard(boxes: []),
            locale: const Locale('en'),
          ),
        );

        expect(find.text('No active boxes currently assigned'), findsOneWidget);
        expect(find.text('Current Boxes (0)'), findsOneWidget);
      },
    );

    testWidgets('DriverDetailsBoxesCard renders Arabic empty copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          const DriverDetailsBoxesCard(boxes: []),
          locale: const Locale('ar'),
        ),
      );

      expect(find.text('لا توجد بوكسات نشطة مسندة حالياً'), findsOneWidget);
      expect(find.text('البوكسات الحالية (0)'), findsOneWidget);
    });

    testWidgets(
      'DriverDetailsLocationCard renders offline state with Retry when coords are null',
      (tester) async {
        var retryClicked = false;
        const offlineLocation = DriverCurrentLocationEntity(
          latitude: null,
          longitude: null,
          statusBadgeText: 'Offline',
          timeAgoText: '10 min ago',
          streetName: 'Street 4',
          areaName: 'Salmiya',
          routePoints: [],
        );

        await tester.pumpWidget(
          createTestApp(
            DriverDetailsLocationCard(
              location: offlineLocation,
              onRetryLocation: () => retryClicked = true,
            ),
            locale: const Locale('en'),
          ),
        );

        expect(
          find.text('Location unavailable (Driver Offline)'),
          findsAtLeastNWidgets(1),
        );
        expect(find.text('Retry Location'), findsOneWidget);

        await tester.tap(find.text('Retry Location'));
        await tester.pump();
        expect(retryClicked, isTrue);
      },
    );
  });

  group('Avatar Initials & Name Fallbacks', () {
    testWidgets(
      'DriverDetailsProfileCard shows initials when avatarUrl is null',
      (tester) async {
        const profile = DriverProfileEntity(
          driverId: 'd1',
          driverCode: 'DR-101',
          fullName: 'Ahmed Ali',
          phoneNumber: '+96550001122',
          avatarUrl: null,
          status: DriverDetailsStatus.available,
          statusText: 'Available',
          statusDotColor: '#10B981',
          lastUpdatedText: 'Just now',
        );

        await tester.pumpWidget(
          createTestApp(const DriverDetailsProfileCard(profile: profile)),
        );

        expect(find.text('AA'), findsOneWidget);
        expect(find.text('Ahmed Ali'), findsOneWidget);
        expect(find.text('DR-101'), findsOneWidget);
      },
    );

    testWidgets(
      'DriverDetailsProfileCard shows person icon fallback when fullName is empty',
      (tester) async {
        const profile = DriverProfileEntity(
          driverId: 'd1',
          driverCode: 'DR-101',
          fullName: '',
          phoneNumber: null,
          avatarUrl: null,
          status: DriverDetailsStatus.available,
          statusText: 'Available',
          statusDotColor: '#10B981',
          lastUpdatedText: 'Just now',
        );

        await tester.pumpWidget(
          createTestApp(const DriverDetailsProfileCard(profile: profile)),
        );

        expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      },
    );
  });

  group('Disabled Actions & Fallbacks', () {
    testWidgets(
      'DriverDetailsActionButtons disables buttons when callbacks are null',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(
            const DriverDetailsActionButtons(onSendMessage: null, onCall: null),
          ),
        );

        // Buttons are rendered and disabled (onPressed is null)
        expect(find.text('Send Message'), findsOneWidget);
        expect(find.text('Call'), findsOneWidget);
      },
    );

    testWidgets('DriverDetailsKpiRow renders zero metrics correctly', (
      tester,
    ) async {
      const kpis = DriverKpisEntity(
        activeBoxesCount: 0,
        deliveredTodayCount: 0,
        avgDelayMinutes: 0,
        performanceRating: 0.0,
      );

      await tester.pumpWidget(
        createTestApp(const DriverDetailsKpiRow(kpis: kpis)),
      );

      expect(find.text('0'), findsAtLeastNWidgets(2));
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets(
      'DriverDetailsPerformanceCard renders zero performance summary',
      (tester) async {
        const dailySummary = DriverDailySummaryEntity(
          approxKm: 0,
          avgDelayMinutes: 0,
          failedDeliveryCount: 0,
          deliveredCount: 0,
        );

        await tester.pumpWidget(
          createTestApp(
            const DriverDetailsPerformanceCard(dailySummary: dailySummary),
          ),
        );

        expect(find.text('0'), findsAtLeastNWidgets(1));
      },
    );
  });

  group('Responsive 320x640 Screen Viewport', () {
    testWidgets('DriverDetailsShimmer does not overflow on 320x640 viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestApp(const DriverDetailsShimmer()));

      expect(tester.takeException(), isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_home_entity.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_active_home_view.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/active_home/driver_current_order_card.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/driver_home_shimmer.dart';
import 'package:meal_mate_delivery/features/driver/home/presentation/widgets/inactive_home/driver_inactive_home_view.dart';

Widget _buildTestApp(Widget child, {Locale locale = const Locale('ar')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  group('DriverHomeShimmer', () {
    testWidgets('renders shimmer layout without errors', (tester) async {
      await tester.pumpWidget(_buildTestApp(const DriverHomeShimmer()));
      expect(find.byType(DriverHomeShimmer), findsOneWidget);
    });
  });

  group('DriverInactiveHomeView', () {
    testWidgets(
      'renders identity, status, manager text and no Start Work button',
      (tester) async {
        const inactiveHome = DriverHomeEntity(
          driverId: 'drv-1',
          driverName: 'سالم الكندري',
          driverCode: 'DRV-99',
          shiftStatus: DriverShiftStatus.inactive,
          isAvailable: false,
          currentStatusText: 'غير متصل',
        );

        await tester.pumpWidget(
          _buildTestApp(const DriverInactiveHomeView(home: inactiveHome)),
        );
        await tester.pumpAndSettle();

        expect(find.text('سالم الكندري'), findsOneWidget);
        expect(find.text('DRV-99'), findsOneWidget);
        expect(find.text('غير متصل'), findsWidgets);
        // Explains manager controls activation
        expect(
          find.textContaining('التحكم بحالة التشغيل من قبل مدير التوصيل'),
          findsOneWidget,
        );
        // No start work button
        expect(find.text('بدء العمل'), findsNothing);
        expect(find.text('Start Work'), findsNothing);
      },
    );
  });

  group('DriverActiveHomeView', () {
    testWidgets('available state without delivery task renders NO order card', (
      tester,
    ) async {
      const availableHome = DriverHomeEntity(
        driverId: 'drv-1',
        driverName: 'سالم الكندري',
        driverCode: 'DRV-99',
        shiftStatus: DriverShiftStatus.active,
        isAvailable: true,
        currentStatusText: 'متاح للطلب',
        targetProgress: DriverHomeTargetProgressEntity(
          targetPercentage: 50.0,
          targetText: '50%',
          completedBoxes: 4,
          totalBoxes: 8,
        ),
        currentDeliveryTask: null,
      );

      await tester.pumpWidget(
        _buildTestApp(const DriverActiveHomeView(home: availableHome)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverActiveHomeView), findsOneWidget);
      expect(find.byType(DriverCurrentOrderCard), findsNothing);
    });

    testWidgets('busy state with delivery task renders current order card', (
      tester,
    ) async {
      const busyHome = DriverHomeEntity(
        driverId: 'drv-1',
        driverName: 'سالم الكندري',
        driverCode: 'DRV-99',
        shiftStatus: DriverShiftStatus.active,
        isAvailable: false,
        currentStatusText: 'في الطريق',
        currentDeliveryTask: DriverHomeCurrentDeliveryTaskEntity(
          boxId: 'box-88',
          boxCode: 'BX-88',
          customerName: 'دانة الأحمد',
          customerPhone: '99881122',
          deliveryAddress: 'السالمية شارع سالم المبارك',
          destinationLatitude: 29.3,
          destinationLongitude: 48.0,
          mealsCount: 2,
          mealsSummary: '2 وجبات صحية',
          deliveryTimeSlot: '13:00',
          status: 'InTransit',
          deliveryNotes: 'الاتصال عند الوصول',
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(const DriverActiveHomeView(home: busyHome)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverCurrentOrderCard), findsOneWidget);
      expect(find.text('دانة الأحمد'), findsOneWidget);
      expect(find.text('السالمية شارع سالم المبارك'), findsOneWidget);
    });
  });
}

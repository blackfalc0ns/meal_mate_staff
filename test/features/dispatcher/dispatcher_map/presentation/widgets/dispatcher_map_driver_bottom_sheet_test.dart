import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_bottom_sheet.dart';

void main() {
  group('DispatcherMapDriverBottomSheet', () {
    Widget buildSubject(
      DispatcherMapDriverEntity driver, {
      VoidCallback? onCall,
      VoidCallback? onViewDetails,
    }) {
      return MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: DispatcherMapDriverBottomSheet(
            driver: driver,
            onCall: onCall,
            onViewDetails: onViewDetails,
          ),
        ),
      );
    }

    testWidgets('renders driver name, driverCode, plateNumber and issue info', (tester) async {
      const driver = DispatcherMapDriverEntity(
        id: 'drv-1',
        driverCode: 'L-98765',
        name: 'أحمد السائق',
        phoneNumber: '+96590001111',
        plateNumber: 'KW-1001',
        boxId: 'BX-194934',
        status: DispatcherMapDriverStatus.hasIssue,
        statusText: 'مشكلة تتطلب انتباه',
        hasIssue: true,
        issueDescription: 'انقطاع إشارة التتبع منذ أكثر من 20 دقيقة',
        locationZone: 'اليرموك',
        remainingDistanceText: '—',
        speed: 0,
      );

      await tester.pumpWidget(buildSubject(driver));
      await tester.pumpAndSettle();

      expect(find.text('أحمد السائق'), findsOneWidget);
      expect(find.text('L-98765'), findsOneWidget);
      expect(find.text('KW-1001'), findsOneWidget);
      expect(find.text('BX-194934'), findsOneWidget);
      expect(find.text('اليرموك'), findsOneWidget);
      expect(find.text('انقطاع إشارة التتبع منذ أكثر من 20 دقيقة'), findsOneWidget);
      expect(find.text('عرض تفاصيل السائق الكاملة'), findsOneWidget);
      expect(find.text('اتصال بالسائق'), findsOneWidget);
    });

    testWidgets('triggers onViewDetails callback when pressed', (tester) async {
      bool detailsTapped = false;
      const driver = DispatcherMapDriverEntity(
        id: 'drv-2',
        driverCode: 'L-10254',
        name: 'فهد العازمي',
        boxId: 'BX-552',
        status: DispatcherMapDriverStatus.inDelivery,
      );

      await tester.pumpWidget(
        buildSubject(
          driver,
          onViewDetails: () => detailsTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('عرض تفاصيل السائق الكاملة'));
      await tester.pumpAndSettle();

      expect(detailsTapped, isTrue);
    });
  });
}

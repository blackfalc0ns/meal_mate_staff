import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/services/driver_contact_launcher.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_badge.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_drivers_status_card.dart';

class _MockContactLauncher extends Fake implements DriverContactLauncher {
  String? lastLaunchedPhone;
  @override
  Future<bool> launchPhone(String? phoneNumber) async {
    lastLaunchedPhone = phoneNumber;
    return true;
  }
}

void main() {
  const driverWithLongData = DispatcherDriverStatusItemEntity(
    driverId: 'driver-1',
    driverCode: '1275765',
    fullName: 'سائق تجريبي بالاسم الكامل',
    phoneNumber: '+96550123456',
    isAvailable: true,
    operationalStatus: DispatcherDriverStatusType.inDelivery,
    rating: 4.8,
    ratingsCount: 34,
    vehicleType: 'Car',
    vehicleModel: 'Honda Civic',
    vehiclePlate: '1275765',
  );

  Widget buildCard({
    required DispatcherDriverStatusItemEntity driver,
    Locale locale = const Locale('ar'),
    ValueChanged<bool>? onToggle,
    VoidCallback? onTap,
    DriverContactLauncher? contactLauncher,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Center(
          child: DispatcherDriversStatusCard(
            driver: driver,
            onToggle: onToggle ?? (_) {},
            onTap: onTap,
            contactLauncher: contactLauncher,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'DispatcherDriversStatusCard renders on 360 width screen without layout overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildCard(driver: driverWithLongData));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(driverWithLongData.name), findsOneWidget);
      expect(find.text('Honda Civic'), findsOneWidget);
      expect(find.text('1275765'), findsWidgets);
      expect(find.byType(DispatcherDriversStatusBadge), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    },
  );

  testWidgets(
    'DispatcherDriversStatusCard renders on 375 width screen in English without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildCard(driver: driverWithLongData, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(driverWithLongData.name), findsOneWidget);
      expect(find.text('Honda Civic'), findsOneWidget);
    },
  );
}

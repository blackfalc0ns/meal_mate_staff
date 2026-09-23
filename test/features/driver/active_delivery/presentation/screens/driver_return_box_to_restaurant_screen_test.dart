import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/fake_data/driver_active_delivery_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_return_box_to_restaurant_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/return_box_actions.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/return_box_form.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/return_box_header.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/return_box_map_view.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/return_box_status_card.dart';

Widget _buildTestApp({
  required Widget child,
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
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverReturnBoxToRestaurantScreen Widget Tests', () {
    testWidgets('renders all components and handles confirm return', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      bool returnConfirmed = false;

      final returnBox = DriverActiveDeliveryFakeData.createReturnBox(
        failureReason: 'العميل لا يجيب على الهاتف',
        note: 'تم الاتصال مرتين',
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverReturnBoxToRestaurantScreen(
            trip: DriverActiveDeliveryFakeData.defaultTrip,
            returnBox: returnBox,
            onConfirmReturn: () => returnConfirmed = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ReturnBoxHeader), findsOneWidget);
      expect(find.byType(ReturnBoxMapView), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
      expect(find.byType(ReturnBoxStatusCard), findsOneWidget);
      expect(find.text('#BX-1256'), findsOneWidget);
      expect(find.text('مطعم برجر ميت'), findsOneWidget);
      expect(find.byType(ReturnBoxForm), findsOneWidget);
      expect(find.text('تم الاتصال مرتين'), findsOneWidget);
      expect(find.byType(ReturnBoxActions), findsOneWidget);

      await tester.ensureVisible(find.byType(ReturnBoxActions));
      await tester.tap(find.byType(ReturnBoxActions));
      await tester.pump();

      expect(returnConfirmed, isTrue);
    });

    testWidgets('renders properly in English LTR locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: const DriverReturnBoxToRestaurantScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Return Box to Restaurant'), findsWidgets);
      expect(find.text('Confirm Restaurant Receipt'), findsOneWidget);
    });
  });
}

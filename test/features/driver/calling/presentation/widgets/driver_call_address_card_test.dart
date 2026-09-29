import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_address_card.dart';

void main() {
  Widget buildSubject({
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
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('DriverCallAddressCard', () {
    testWidgets('renders address title, address line, area, and location pin in Arabic', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          child: const DriverCallAddressCard(
            addressLine: 'شارع الخليج العربي ، قطعة 12 ، منزل 45',
            area: 'السلمانية',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('العنوان'), findsOneWidget);
      expect(find.text('شارع الخليج العربي ، قطعة 12 ، منزل 45'), findsOneWidget);
      expect(find.text('السلمانية'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('renders address title in English', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          locale: const Locale('en'),
          child: const DriverCallAddressCard(
            addressLine: 'Arabian Gulf St, Block 12, House 45',
            area: 'Salmiya',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Arabian Gulf St, Block 12, House 45'), findsOneWidget);
      expect(find.text('Salmiya'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });
  });
}

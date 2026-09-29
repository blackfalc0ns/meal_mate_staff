import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_header.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_top_bar.dart';

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
      home: Scaffold(body: child),
    );
  }

  group('DriverCallTopBar', () {
    testWidgets('renders chevron down icon and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildSubject(
          child: DriverCallTopBar(onDismiss: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();

      final chevronFinder = find.byIcon(Icons.keyboard_arrow_down_rounded);
      expect(chevronFinder, findsOneWidget);

      await tester.tap(chevronFinder);
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('DriverCallHeader', () {
    testWidgets('renders call in progress, customer name, and duration in Arabic', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          child: const DriverCallHeader(
            customerName: 'محمد علي',
            durationText: '00:24',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('اتصال جاري...'), findsOneWidget);
      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.text('00:24'), findsOneWidget);
    });

    testWidgets('renders call in progress in English', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          locale: const Locale('en'),
          child: const DriverCallHeader(
            customerName: 'Mohammad Ali',
            durationText: '01:15',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Call in progress...'), findsOneWidget);
      expect(find.text('Mohammad Ali'), findsOneWidget);
      expect(find.text('01:15'), findsOneWidget);
    });
  });
}

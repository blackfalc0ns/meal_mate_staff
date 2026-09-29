import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/screens/driver_support_tickets_screen.dart';

void main() {
  testWidgets('DriverSupportTicketsScreen filters tickets by KPI and search query', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ar'),
        home: DriverSupportTicketsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state shows tickets
    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('#BX-1257'), findsOneWidget);
    expect(find.text('#BX-1258'), findsOneWidget);

    // Filter by KPI: underReview (count: 2)
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('#BX-1260'), findsOneWidget);
    expect(find.text('#BX-1257'), findsNothing);

    // Search for 1260
    await tester.enterText(find.byType(TextField), '1260');
    await tester.pumpAndSettle();

    expect(find.text('#BX-1260'), findsOneWidget);
    expect(find.text('#BX-1256'), findsNothing);

    // Search query with no match
    await tester.enterText(find.byType(TextField), 'nonexistent_query');
    await tester.pumpAndSettle();

    expect(find.text('لا توجد بلاغات تطابق البحث'), findsOneWidget);
  });

  testWidgets('DriverSupportTicketsScreen scrolls smoothly in CustomScrollView at phone size', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ar'),
        home: DriverSupportTicketsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomScrollView), findsOneWidget);

    // Scroll down to reveal bottom elements
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // Verify pinned header elements are still present on screen
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
  });
}

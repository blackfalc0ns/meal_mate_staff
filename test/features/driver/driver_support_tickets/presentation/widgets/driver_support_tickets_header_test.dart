import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_search_field.dart';

void main() {
  testWidgets('DriverSupportTicketsHeader and SearchField render with localization', (tester) async {
    final controller = TextEditingController();
    var changedText = '';

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          appBar: const DriverSupportTicketsHeader(),
          body: DriverSupportTicketsSearchField(
            controller: controller,
            onChanged: (val) => changedText = val,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DriverSupportTicketsHeader), findsOneWidget);
    expect(find.byType(DriverSupportTicketsSearchField), findsOneWidget);
    expect(find.text('الدعم'), findsOneWidget);
    expect(find.text('تابع البلاغات المفتوحة بسرعة'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1234');
    expect(changedText, '1234');
  });
}

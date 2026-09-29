import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_list.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_report_button.dart';

void main() {
  testWidgets('DriverSupportTicketsList renders all tickets and ReportButton responds to tap', (tester) async {
    var reported = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: Column(
            children: [
              const Expanded(
                child: DriverSupportTicketsList(
                  tickets: DriverSupportTicketsFakeData.tickets,
                ),
              ),
              DriverSupportTicketsReportButton(
                onPressed: () => reported = true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('#BX-1257'), findsOneWidget);
    expect(find.text('إبلاغ عن مشكلة جديدة'), findsOneWidget);

    await tester.tap(find.byType(DriverSupportTicketsReportButton));
    expect(reported, isTrue);
  });
}

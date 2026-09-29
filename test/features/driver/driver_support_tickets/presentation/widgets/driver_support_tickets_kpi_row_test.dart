import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_tickets_kpi_row.dart';

void main() {
  testWidgets('DriverSupportTicketsKpiRow renders 4 filter cards and responds to taps', (tester) async {
    var selected = DriverSupportTicketFilter.all;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return DriverSupportTicketsKpiRow(
                selectedFilter: selected,
                allCount: 6,
                underReviewCount: 2,
                awaitingResponseCount: 1,
                resolvedCount: 3,
                onFilterChanged: (filter) {
                  setState(() {
                    selected = filter;
                  });
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('6'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(selected, DriverSupportTicketFilter.underReview);
  });
}

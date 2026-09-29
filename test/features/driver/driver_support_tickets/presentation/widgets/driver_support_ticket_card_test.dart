import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/widgets/driver_support_ticket_card.dart';

void main() {
  testWidgets('DriverSupportTicketCard renders ticket info and handles tap', (tester) async {
    const ticket = DriverSupportTicketEntity(
      id: '1',
      boxNumber: '#BX-1256',
      title: 'العميل غير متواجد',
      location: 'منطقة السالمية',
      updatedAt: 'آخر تحديث منذ 20 دقيقة',
      status: DriverSupportTicketStatus.underReview,
    );

    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: DriverSupportTicketCard(
            ticket: ticket,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('العميل غير متواجد'), findsOneWidget);
    expect(find.text('منطقة السالمية'), findsOneWidget);
    expect(find.text('آخر تحديث منذ 20 دقيقة'), findsOneWidget);
    expect(find.text('عرض التفاصيل'), findsOneWidget);
    expect(find.text('قيد المراجعة'), findsOneWidget);

    await tester.tap(find.byType(DriverSupportTicketCard));
    expect(tapped, isTrue);
  });
}

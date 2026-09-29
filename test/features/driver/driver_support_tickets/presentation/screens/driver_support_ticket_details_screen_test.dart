import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/fake_data/driver_support_tickets_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/screens/driver_support_ticket_details_screen.dart';

void main() {
  testWidgets('DriverSupportTicketDetailsScreen renders all sections in Arabic', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var contactSupportCalled = false;
    var backPressedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: DriverSupportTicketDetailsScreen(
          ticket: DriverSupportTicketsFakeData.tickets.first,
          onContactSupport: () => contactSupportCalled = true,
          onBackPressed: () => backPressedCalled = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('تفاصيل البلاغ'), findsOneWidget);
    expect(find.text('متابعة حالة البلاغ ومعرفة آخر التحديثات'), findsOneWidget);

    // 2. Summary Card
    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('العميل غير متواجد'), findsOneWidget);
    expect(find.text('منطقة السالمية'), findsWidgets);
    expect(find.text('تم الإنشاء'), findsOneWidget);

    // 3. Timeline Card
    expect(find.text('سير البلاغ'), findsOneWidget);
    expect(find.text('تم استلام البلاغ'), findsOneWidget);
    expect(find.text('قيد المراجعة'), findsWidgets);
    expect(find.text('جار التواصل مع العميل'), findsOneWidget);
    expect(find.text('تم الحل'), findsOneWidget);

    // 4. Issue Description Card
    expect(find.text('تفاصيل المشكلة'), findsOneWidget);
    expect(
      find.text(
        'وصلت إلى موقع العميل ولم يكن متواجد، حاولت التواصل عبر الهاتف ولم يتم الرد.',
      ),
      findsOneWidget,
    );

    // 5. Attached Photos Card
    expect(find.text('الصور المرفقة'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // 6. Order Information Card
    expect(find.text('معلومات الطلب'), findsOneWidget);
    expect(find.text('رقم الطلب'), findsOneWidget);
    expect(find.text('#12345'), findsOneWidget);
    expect(find.text('وقت الطلب'), findsOneWidget);
    expect(find.text('عنوان التوصيل'), findsOneWidget);

    // 7. Contact Support Button
    expect(find.text('التواصل مع الدعم'), findsOneWidget);
    await tester.tap(find.text('التواصل مع الدعم'));
    expect(contactSupportCalled, isTrue);

    // 8. Back button tap
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    expect(backPressedCalled, isTrue);

    // 9. Verify Attached Photos: Add button is to the left of the first image
    final addButtonPos = tester.getTopLeft(find.byIcon(Icons.add_rounded));
    final firstImagePos = tester.getTopLeft(find.byType(Image).at(1));
    expect(addButtonPos.dx, lessThan(firstImagePos.dx));

    // 10. Verify Timeline in RTL: Indicator is on the RIGHT (greater dx) of the step title
    final step1TitlePos = tester.getTopLeft(find.text('تم استلام البلاغ'));
    final step1IndicatorPos = tester.getTopLeft(find.byIcon(Icons.check_rounded).first);
    expect(step1IndicatorPos.dx, greaterThan(step1TitlePos.dx));
  });

  testWidgets('DriverSupportTicketDetailsScreen renders all sections in English', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: DriverSupportTicketDetailsScreen(
          ticket: DriverSupportTicketsFakeData.tickets.first,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ticket Details'), findsOneWidget);
    expect(find.text('Ticket Progress'), findsOneWidget);
    expect(find.text('Issue Details'), findsOneWidget);
    expect(find.text('Attached Photos'), findsOneWidget);
    expect(find.text('Order Information'), findsOneWidget);
    expect(find.text('Order Number'), findsOneWidget);
    expect(find.text('Order Time'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
  });
}

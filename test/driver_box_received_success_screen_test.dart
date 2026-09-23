import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_box_received_success_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_box_received_success_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_received_detail_row.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_received_details_card.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_received_next_button.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_received_safety_card.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_received_success_header.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_received_success_illustration.dart';

void main() {
  Widget buildSubject({
    DriverBoxReceivedSuccessEntity? box,
    VoidCallback? onNextOrder,
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
      home: DriverBoxReceivedSuccessScreen(
        box: box,
        onNextOrder: onNextOrder,
      ),
    );
  }

  testWidgets('renders all components and values in Arabic RTL', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(DriverBoxReceivedSuccessIllustration), findsOneWidget);
    expect(find.byType(DriverBoxReceivedSuccessHeader), findsOneWidget);
    expect(find.byType(DriverBoxReceivedDetailsCard), findsOneWidget);
    expect(find.byType(DriverBoxReceivedDetailRow), findsNWidgets(3));
    expect(find.byType(DriverBoxReceivedSafetyCard), findsOneWidget);
    expect(find.byType(DriverBoxReceivedNextButton), findsOneWidget);

    expect(find.text('تم استلام البوكس بنجاح'), findsOneWidget);
    expect(
      find.text('تم ربط البوكس بنجاح بحسابك وهو الآن جاهز للتوصيل'),
      findsOneWidget,
    );
    expect(find.text('#BX-9876'), findsOneWidget);
    expect(find.text('تم الاستلام'), findsOneWidget);
    expect(find.text('رقم البوكس'), findsOneWidget);
    expect(find.text('المطعم'), findsOneWidget);
    expect(find.text('مطعم MealMate الكويت'), findsOneWidget);
    expect(find.text('عدد الأصناف'), findsOneWidget);
    expect(find.text('3 وجبات'), findsOneWidget);
    expect(find.text('وقت الاستلام المتوقع'), findsOneWidget);
    expect(find.text('9:30 ص - 9 مايو 2025'), findsOneWidget);
    expect(find.text('تأكد من سلامة البوكس'), findsOneWidget);
    expect(find.text('الانتقال الى الطلب التالي'), findsOneWidget);
  });

  testWidgets('renders all components and values in English LTR', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Box Received Successfully'), findsOneWidget);
    expect(
      find.text(
        'The box has been successfully linked to your account and is now ready for delivery',
      ),
      findsOneWidget,
    );
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Box Number'), findsOneWidget);
    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Number of Items'), findsOneWidget);
    expect(find.text('3 Meals'), findsOneWidget);
    expect(find.text('Expected Receipt Time'), findsOneWidget);
    expect(find.text('Check Box Safety'), findsOneWidget);
    expect(find.text('Proceed to Next Order'), findsOneWidget);
  });

  testWidgets('triggers onNextOrder callback when button is tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    var tapped = false;
    await tester.pumpWidget(
      buildSubject(onNextOrder: () => tapped = true),
    );
    await tester.pumpAndSettle();

    final buttonFinder = find.byType(DriverBoxReceivedNextButton);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}

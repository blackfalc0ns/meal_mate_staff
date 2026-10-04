import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_box_not_assigned_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_box_not_assigned_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_not_assigned_actions.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_not_assigned_card.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_not_assigned_header.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_not_assigned_illustration.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_box_not_assigned_info_card.dart';

void main() {
  Widget buildTestWidget({
    DriverBoxNotAssignedEntity? box,
    VoidCallback? onScanAnotherCode,
    VoidCallback? onContactRestaurant,
    VoidCallback? onReturnToBoxesList,
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
      home: DriverBoxNotAssignedScreen(
        box: box,
        onScanAnotherCode: onScanAnotherCode,
        onContactRestaurant: onContactRestaurant,
        onReturnToBoxesList: onReturnToBoxesList,
      ),
    );
  }

  testWidgets('renders all widgets properly in Arabic', (tester) async {
    const entity = DriverBoxNotAssignedEntity(
      boxCode: '#BX-9876',
      restaurantPhone: '12345678',
    );

    await tester.pumpWidget(buildTestWidget(box: entity, locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.byType(DriverBoxNotAssignedIllustration), findsOneWidget);
    expect(find.byType(DriverBoxNotAssignedHeader), findsOneWidget);
    expect(find.byType(DriverBoxNotAssignedCard), findsOneWidget);
    expect(find.byType(DriverBoxNotAssignedInfoCard), findsOneWidget);
    expect(find.byType(DriverBoxNotAssignedActions), findsOneWidget);

    expect(find.text('#BX-9876'), findsOneWidget);
    expect(find.text('هذا الرمز لا يخصك'), findsOneWidget);
    expect(find.text('رمز QR الذي قمت بمسحه لا يخص أي بوكس مسند إليك حالياً'), findsOneWidget);
    expect(find.text('غير مسند لك'), findsOneWidget);
    expect(find.text('ماذا يمكنك فعله؟'), findsOneWidget);
    expect(find.text('مسح رمز آخر'), findsOneWidget);
    expect(find.text('التواصل مع المطعم'), findsOneWidget);
    expect(find.text('العودة إلى قائمة البوكسات'), findsOneWidget);
  });

  testWidgets('renders properly in English', (tester) async {
    const entity = DriverBoxNotAssignedEntity(
      boxCode: '#BX-9876',
    );

    await tester.pumpWidget(buildTestWidget(box: entity, locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('#BX-9876'), findsOneWidget);
    expect(find.text('This Code Does Not Belong to You'), findsOneWidget);
    expect(find.text('Not Assigned to You'), findsOneWidget);
    expect(find.text('Scan Another Code'), findsOneWidget);
    expect(find.text('Contact the Restaurant'), findsOneWidget);
    expect(find.text('Return to Boxes List'), findsOneWidget);
  });

  testWidgets('triggers action callbacks when buttons are tapped', (tester) async {
    bool scannedTapped = false;
    bool contactTapped = false;
    bool returnTapped = false;

    const entity = DriverBoxNotAssignedEntity(boxCode: '#BX-9876');

    await tester.pumpWidget(
      buildTestWidget(
        box: entity,
        onScanAnotherCode: () => scannedTapped = true,
        onContactRestaurant: () => contactTapped = true,
        onReturnToBoxesList: () => returnTapped = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('مسح رمز آخر'));
    await tester.tap(find.text('مسح رمز آخر'));
    expect(scannedTapped, isTrue);

    await tester.ensureVisible(find.text('التواصل مع المطعم'));
    await tester.tap(find.text('التواصل مع المطعم'));
    expect(contactTapped, isTrue);

    await tester.ensureVisible(find.text('العودة إلى قائمة البوكسات'));
    await tester.tap(find.text('العودة إلى قائمة البوكسات'));
    expect(returnTapped, isTrue);
  });
}

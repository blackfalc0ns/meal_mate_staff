import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_received_box_item_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_boxes_received_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_action_button.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_header.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_info_card.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_safety_banner.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_boxes_received_success_banner.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_received_box_card.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_received_boxes_header_bar.dart';

void main() {
  Widget buildSubject({
    List<DriverReceivedBoxItemEntity>? boxes,
    VoidCallback? onStartDelivery,
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
      home: DriverBoxesReceivedScreen(
        boxes: boxes,
        onStartDelivery: onStartDelivery,
      ),
    );
  }

  testWidgets('renders all major components and cards in RTL Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(DriverBoxesReceivedHeader), findsOneWidget);
    expect(find.byType(DriverBoxesReceivedSuccessBanner), findsOneWidget);
    expect(find.byType(DriverBoxesReceivedInfoCard), findsOneWidget);
    expect(find.byType(DriverReceivedBoxesHeaderBar), findsOneWidget);
    expect(find.byType(DriverReceivedBoxCard), findsNWidgets(5));
    expect(find.byType(DriverBoxesReceivedSafetyBanner), findsOneWidget);
    expect(find.byType(DriverBoxesReceivedActionButton), findsOneWidget);

    expect(find.text('تم استلام الصناديق'), findsOneWidget);
    expect(find.text('تم استلام 5 صناديق بنجاح'), findsOneWidget);
    expect(find.text('مركز الوجبات - النرجس'), findsOneWidget);
    expect(find.text('بدء التوصيل'), findsOneWidget);
  });

  testWidgets('renders all major components in English LTR', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Boxes Received'), findsOneWidget);
    expect(find.text('5 Boxes Received Successfully'), findsOneWidget);
    expect(find.text('Meal Center - Al Narjis'), findsOneWidget);
    expect(find.text('Start Delivery'), findsOneWidget);
  });

  testWidgets(
    'triggers onStartDelivery callback when action button is tapped',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      var tapped = false;
      await tester.pumpWidget(
        buildSubject(onStartDelivery: () => tapped = true),
      );
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(DriverBoxesReceivedActionButton);
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    },
  );
}

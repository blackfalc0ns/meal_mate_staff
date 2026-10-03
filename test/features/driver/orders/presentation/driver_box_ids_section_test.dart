import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_box_ids_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildSubject({
    String? boxCode,
    String? boxId,
    String? orderCode,
    String? customerName,
  }) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: DriverBoxIdsSection(
            boxCode: boxCode,
            boxId: boxId,
            orderCode: orderCode,
            customerName: customerName,
          ),
        ),
      ),
    );
  }

  group('DriverBoxIdsSection', () {
    testWidgets('renders boxCode and does not render boxId UUID', (tester) async {
      const testUuid = '5f98ec9a-7199-e011-8234-00155d00010a';
      const testBoxCode = 'BX-4251#';

      await tester.pumpWidget(
        buildSubject(
          boxCode: testBoxCode,
          boxId: testUuid,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testBoxCode), findsOneWidget);
      expect(find.text(testUuid), findsNothing);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('tapping copies boxCode to clipboard', (tester) async {
      const testBoxCode = 'BX-4251#';
      final List<MethodCall> log = [];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'Clipboard.setData') {
          return null;
        }
        return null;
      });

      await tester.pumpWidget(
        buildSubject(boxCode: testBoxCode),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(testBoxCode));
      await tester.pumpAndSettle();

      final setDataCalls = log.where((call) => call.method == 'Clipboard.setData').toList();
      expect(setDataCalls, isNotEmpty);
      expect(setDataCalls.last.arguments, {'text': testBoxCode});
    });

    testWidgets('renders customerName when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          boxCode: 'BX-1256#',
          customerName: 'سارة العتيبي',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سارة العتيبي'), findsOneWidget);
      expect(find.text('BX-1256#'), findsOneWidget);
    });
  });
}

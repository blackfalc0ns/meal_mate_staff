import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/widgets/delivery_issue_reason_selector.dart';

Widget _buildTestWidget({
  required DeliveryIssueReason selectedReason,
  required ValueChanged<DeliveryIssueReason> onReasonSelected,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: Scaffold(
      body: SingleChildScrollView(
        child: DeliveryIssueReasonSelector(
          selectedReason: selectedReason,
          onReasonSelected: onReasonSelected,
        ),
      ),
    ),
  );
}

void main() {
  group('DeliveryIssueReasonSelector', () {
    testWidgets('renders all 5 reasons and handles selection', (tester) async {
      DeliveryIssueReason selected = DeliveryIssueReason.customerNoAnswer;

      await tester.pumpWidget(
        _buildTestWidget(
          selectedReason: selected,
          onReasonSelected: (reason) {
            selected = reason;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('اختر سبب المشكلة'), findsOneWidget);
      expect(find.text('العميل لا يرد'), findsOneWidget);
      expect(find.text('العنوان غير واضح'), findsOneWidget);
      expect(find.text('تأخير شديد'), findsOneWidget);
      expect(find.text('الصندوق تالف'), findsOneWidget);
      expect(find.text('رفض الاستلام'), findsOneWidget);

      await tester.tap(find.text('الصندوق تالف'));
      await tester.pumpAndSettle();

      expect(selected, DeliveryIssueReason.boxDamaged);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/fake_data/delivery_issues_fake_data.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/widgets/delivery_issue_box_summary_card.dart';

Widget _buildTestWidget() {
  return const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [Locale('ar'), Locale('en')],
    locale: Locale('ar'),
    home: Scaffold(
      body: DeliveryIssueBoxSummaryCard(
        issue: DeliveryIssuesFakeData.defaultIssue,
      ),
    ),
  );
}

void main() {
  group('DeliveryIssueBoxSummaryCard', () {
    testWidgets('renders box summary details properly', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('#BX-1257'), findsOneWidget);
      expect(find.text('مطعم MealMate الكويت'), findsOneWidget);
      expect(find.text('أحمد إبراهيم'), findsOneWidget);
      expect(find.text('منطقة حولي'), findsOneWidget);
      expect(find.text('في الطريق للعميل'), findsOneWidget);
      expect(find.text('1 من 1 وجبة'), findsOneWidget);
      expect(find.text('الصندوق الحالي'), findsOneWidget);
    });
  });
}

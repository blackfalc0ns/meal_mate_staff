import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/widgets/delivery_issue_action_buttons.dart';

Widget _buildTestWidget({
  required VoidCallback onSubmit,
  required VoidCallback onRequestReassign,
  required VoidCallback onCallSupervisor,
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
      body: DeliveryIssueActionButtons(
        onSubmit: onSubmit,
        onRequestReassign: onRequestReassign,
        onCallSupervisor: onCallSupervisor,
      ),
    ),
  );
}

void main() {
  group('DeliveryIssueActionButtons', () {
    testWidgets('renders action buttons and triggers callbacks',
        (tester) async {
      bool submitted = false;
      bool requestedReassign = false;
      bool calledSupervisor = false;

      await tester.pumpWidget(
        _buildTestWidget(
          onSubmit: () => submitted = true,
          onRequestReassign: () => requestedReassign = true,
          onCallSupervisor: () => calledSupervisor = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إرسال للمشرف'), findsOneWidget);
      expect(find.text('طلب إعادة إسناد'), findsOneWidget);
      expect(find.text('اتصال بالمشرف'), findsOneWidget);

      await tester.tap(find.text('إرسال للمشرف'));
      expect(submitted, isTrue);

      await tester.tap(find.text('طلب إعادة إسناد'));
      expect(requestedReassign, isTrue);

      await tester.tap(find.text('اتصال بالمشرف'));
      expect(calledSupervisor, isTrue);
    });
  });
}

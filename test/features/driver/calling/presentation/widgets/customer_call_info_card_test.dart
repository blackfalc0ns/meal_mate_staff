import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/customer_call_info_card.dart';

Widget _buildTestWidget({
  required String customerName,
  required String customerPhone,
  required bool isPhoneUnlocked,
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
      body: CustomerCallInfoCard(
        customerName: customerName,
        customerPhone: customerPhone,
        isPhoneUnlocked: isPhoneUnlocked,
      ),
    ),
  );
}

void main() {
  group('CustomerCallInfoCard', () {
    testWidgets('renders protected phone badge when isPhoneUnlocked is false',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        customerName: 'محمد علي',
        customerPhone: '+966 50 123 4567',
        isPhoneUnlocked: false,
      ));
      await tester.pumpAndSettle();

      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.text('رقم الهاتف محمي'), findsOneWidget);
      expect(find.text('+966 50 123 4567'), findsNothing);
    });

    testWidgets('renders external unlocked badge and phone number when isPhoneUnlocked is true',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        customerName: 'محمد علي',
        customerPhone: '+966 50 123 4567',
        isPhoneUnlocked: true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('محمد علي'), findsOneWidget);
      expect(find.text('تم إتاحة الاتصال الخارجي'), findsOneWidget);
      expect(find.text('+966 50 123 4567'), findsOneWidget);
    });
  });
}

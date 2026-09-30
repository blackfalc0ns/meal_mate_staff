import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_reassignment_request_screen.dart';

Widget _buildTestWidget({
  ValueChanged<ReassignmentRequestEntity>? onSubmitRequest,
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
    home: DriverReassignmentRequestScreen(
      onSubmitRequest: onSubmitRequest,
    ),
  );
}

void main() {
  group('DriverReassignmentRequestScreen', () {
    testWidgets('renders hero illustration and submits request',
        (tester) async {
      ReassignmentRequestEntity? submitted;

      await tester.pumpWidget(
        _buildTestWidget(
          onSubmitRequest: (req) => submitted = req,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('طلب إعادة إسناد'), findsWidgets);
      expect(find.text('سبب الطلب'), findsOneWidget);
      expect(find.text('إرسال الطلب'), findsOneWidget);

      await tester.tap(find.text('إرسال الطلب'));
      await tester.pumpAndSettle();

      expect(submitted, isNotNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/widgets/reassignment_reason_dropdown.dart';

Widget _buildTestWidget({
  required ReassignmentReason? selectedReason,
  required ValueChanged<ReassignmentReason?> onChanged,
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
      body: ReassignmentReasonDropdown(
        selectedReason: selectedReason,
        onChanged: onChanged,
      ),
    ),
  );
}

void main() {
  group('ReassignmentReasonDropdown', () {
    testWidgets('renders dropdown with label and selected value',
        (tester) async {
      ReassignmentReason? selected = ReassignmentReason.vehicleBreakdown;

      await tester.pumpWidget(
        _buildTestWidget(
          selectedReason: selected,
          onChanged: (val) => selected = val,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سبب الطلب'), findsOneWidget);
      expect(find.text('عطل في المركبة'), findsOneWidget);
    });
  });
}

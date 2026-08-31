import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/register/presentation/widgets/register_plate_number_field.dart';

void main() {
  testWidgets('places Kuwait selector to the right of the plate input', (
    tester,
  ) async {
    late final AppLocalizations locale;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            locale = AppLocalizations.of(context)!;

            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: RegisterPlateNumberField(locale: locale),
              ),
            );
          },
        ),
      ),
    );

    final kuwaitLeft = tester.getTopLeft(find.text('Kuwait')).dx;
    final inputLeft = tester.getTopLeft(find.byType(TextFormField)).dx;

    expect(kuwaitLeft, greaterThan(inputLeft));
  });
}

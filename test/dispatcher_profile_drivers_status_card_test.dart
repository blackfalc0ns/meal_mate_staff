import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_profile/presentation/widgets/dispatcher_profile_drivers_status_card.dart';

void main() {
  testWidgets('DispatcherProfileDriversStatusCard renders and responds to tap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: DispatcherProfileDriversStatusCard(
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DispatcherProfileDriversStatusCard), findsOneWidget);
    expect(find.text('حالة السائقين'), findsOneWidget);

    await tester.tap(find.byType(DispatcherProfileDriversStatusCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}

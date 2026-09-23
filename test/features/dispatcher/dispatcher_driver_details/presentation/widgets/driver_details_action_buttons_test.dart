import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_action_buttons.dart';

Widget createLocalizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ar')],
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('DriverDetailsActionButtons', () {
    testWidgets('calls onCall when call button is tapped', (tester) async {
      var callTapped = false;

      await tester.pumpWidget(
        createLocalizedApp(
          DriverDetailsActionButtons(
            onCall: () => callTapped = true,
            onSendMessage: () {},
          ),
        ),
      );

      await tester.tap(find.text('Call'));
      expect(callTapped, isTrue);
    });

    testWidgets(
      'shows modal bottom sheet with SMS and WhatsApp choices when message tapped',
      (tester) async {
        var smsSelected = false;
        var whatsAppSelected = false;

        await tester.pumpWidget(
          createLocalizedApp(
            DriverDetailsActionButtons(
              onCall: () {},
              onSelectSms: () => smsSelected = true,
              onSelectWhatsApp: () => whatsAppSelected = true,
            ),
          ),
        );

        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();

        expect(find.text('Choose Messaging App'), findsOneWidget);
        expect(find.text('SMS'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
        // No internal chat
        expect(find.text('Internal Chat'), findsNothing);

        await tester.tap(find.text('SMS'));
        await tester.pumpAndSettle();
        expect(smsSelected, isTrue);
        expect(whatsAppSelected, isFalse);

        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('WhatsApp'));
        await tester.pumpAndSettle();
        expect(whatsAppSelected, isTrue);
      },
    );

    testWidgets('disables both buttons when callbacks/phone is not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const DriverDetailsActionButtons(onCall: null, onSendMessage: null),
        ),
      );

      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);
    });
  });
}

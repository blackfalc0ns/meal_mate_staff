import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_nationality_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_restaurant_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/register_personal_data.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_personal_data_screen.dart';

const _restaurants = [
  DriverRestaurantEntity(
    id: 'res-1',
    tradeName: 'Burger King',
    tradeNameAr: 'برجر كنج',
    tradeNameEn: 'Burger King',
  ),
];

const _nationalities = [
  DriverNationalityEntity(
    code: 'KW',
    name: 'Kuwaiti',
    nameAr: 'كويتي',
    nameEn: 'Kuwaiti',
    countryName: 'Kuwait',
    countryNameAr: 'الكويت',
    countryNameEn: 'Kuwait',
    flagEmoji: '🇰🇼',
  ),
];

Widget _app({
  RegisterPersonalData? initialData,
  ValueChanged<RegisterPersonalData>? onPersonalDataChanged,
  VoidCallback? onContinue,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    home: RegisterPersonalDataScreen(
      initialData: initialData,
      restaurants: _restaurants,
      nationalities: _nationalities,
      onPersonalDataChanged: onPersonalDataChanged,
      onContinue: onContinue ?? () {},
    ),
  );
}

void main() {
  testWidgets('renders password field obscured by default', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Password'), findsOneWidget);

    final passwordField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('driver_registration_password_field')),
        matching: find.byType(TextField),
      ),
    );
    expect(passwordField.obscureText, isTrue);
  });

  testWidgets('validation fails when password is empty on continue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var continued = false;
    await tester.pumpWidget(
      _app(
        initialData: const RegisterPersonalData(
          firstName: 'John',
          lastName: 'Doe',
          phone: '+96550000000',
          email: 'john@example.com',
          birthDate: '1995/05/15',
          nationality: 'Kuwaiti',
          civilId: '123456789012',
          restaurantId: 'res-1',
          restaurantName: 'Burger King',
          fullNameAr: 'جون دو',
          fullNameEn: 'John Doe',
          nationalIdExpiry: '2030-01-01',
          password: '',
        ),
        onContinue: () => continued = true,
      ),
    );
    await tester.pumpAndSettle();

    final continueBtn = find.byType(AppButton);
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(continued, isFalse);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets(
    'toggling visibility changes obscureText without losing entered password',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final passwordFinder = find.byKey(
        const Key('driver_registration_password_field'),
      );
      await tester.enterText(passwordFinder, 'Password123!');
      await tester.pump();

      var passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isTrue);

      final eyeIcon = find.byIcon(Icons.visibility_off_outlined);
      expect(eyeIcon, findsOneWidget);
      await tester.tap(eyeIcon);
      await tester.pump();

      passwordField = tester.widget<TextField>(
        find.descendant(
          of: passwordFinder,
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isFalse);
      expect(passwordField.controller?.text, 'Password123!');
    },
  );
}

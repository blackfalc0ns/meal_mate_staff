import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_screen.dart';

import 'dart:io';

import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_file_upload_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_draft_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_restaurant_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_nationality_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_resubmit_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_color_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_model_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_type_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/repo/driver_registration_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestRegistrationRepo implements DriverRegistrationRepository {
  @override
  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities() async =>
      ApiSuccessResult(
        data: const [
          DriverNationalityEntity(
            code: 'KW',
            name: 'Kuwaiti',
            nameAr: 'Kuwaiti',
            nameEn: 'Kuwaiti',
            countryName: 'Kuwait',
            countryNameAr: 'Kuwait',
            countryNameEn: 'Kuwait',
            flagEmoji: 'KW',
          ),
        ],
      );

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async =>
      ApiSuccessResult(
        data: const [
          DriverRestaurantEntity(
            id: 'res-1',
            tradeName: 'Balance Box',
            tradeNameAr: 'Balance Box',
            tradeNameEn: 'Balance Box',
          ),
        ],
      );

  @override
  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes() async =>
      ApiSuccessResult(
        data: const [
          DriverVehicleTypeEntity(
            code: 'Car',
            nameAr: 'سيارة',
            nameEn: 'Passenger car',
            iconKey: 'car',
          ),
        ],
      );

  @override
  Future<ApiResult<List<DriverVehicleColorEntity>>> getVehicleColors() async =>
      ApiSuccessResult(
        data: const [
          DriverVehicleColorEntity(
            hex: '#112233',
            nameAr: 'كحلي',
            nameEn: 'Navy',
            isDefault: true,
            displayOrder: 1,
          ),
        ],
      );

  @override
  Future<ApiResult<List<DriverVehicleModelEntity>>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) async => ApiSuccessResult(data: const []);

  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(
    File file,
  ) async => ApiSuccessResult(
    data: const DriverFileUploadResultEntity(storageKey: 'key'),
  );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) async => ApiSuccessResult(
    data: const DriverRegistrationResultEntity(
      registrationId: 'reg-1',
      restaurantId: 'res-1',
      restaurantName: 'Balance Box',
      phone: '+966501234567',
      status: 'Submitted',
      message: 'Submitted',
    ),
  );

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) async => ApiSuccessResult(
    data: const DriverRegistrationResultEntity(
      registrationId: 'reg-1',
      restaurantId: 'res-1',
      restaurantName: 'Balance Box',
      phone: '+966501234567',
      status: 'Submitted',
      message: 'Submitted',
    ),
  );
}

Future<void> _completePersonalAndContinue(WidgetTester tester) async {
  await tester.pumpAndSettle();
  var fields = find.byType(TextFormField);
  await tester.ensureVisible(fields.at(0));
  await tester.tap(fields.at(0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Balance Box').last);
  await tester.pumpAndSettle();

  fields = find.byType(TextFormField);
  await tester.enterText(fields.at(1), 'Ahmed Arabic Name');
  await tester.enterText(fields.at(2), 'Ahmed Mohamed');
  await tester.enterText(fields.at(3), '+966501234567');
  await tester.enterText(fields.at(7), '1234567890');
  await tester.ensureVisible(fields.at(6));
  await tester.tap(fields.at(6));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Kuwaiti').last);
  await tester.pumpAndSettle();
  fields = find.byType(TextFormField);
  await tester.ensureVisible(fields.at(8));
  await tester.tap(fields.at(8));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(AppButton).last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<void> _completeVehicleAndContinue(WidgetTester tester) async {
  await tester.pumpAndSettle();
  var fields = find.byType(TextFormField);
  await tester.tap(fields.at(0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Passenger car').last);
  await tester.pumpAndSettle();
  fields = find.byType(TextFormField);
  await tester.enterText(fields.at(1), 'Toyota');
  await tester.enterText(fields.at(2), '2026');
  await tester.enterText(fields.at(3), '54821');
  await tester.enterText(fields.at(4), 'DL-839201');
  await tester.ensureVisible(fields.at(5));
  await tester.tap(fields.at(5));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(AppButton).last);
  await tester.pumpAndSettle();
  fields = find.byType(TextFormField);
  await tester.ensureVisible(fields.at(6));
  await tester.tap(fields.at(6));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(AppButton).last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byTooltip('Navy'));
  await tester.tap(find.byTooltip('Navy'));
  await tester.pump();
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  if (find.text('Civil card').evaluate().isEmpty) {
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .where(
          (text) =>
              text.contains('required') ||
              text.contains('future') ||
              text.contains('year'),
        )
        .join(' | ');
    fail('Vehicle form did not advance: $texts');
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    getIt.allowReassignment = true;
    getIt.registerLazySingleton<DriverRegistrationRepository>(
      () => _TestRegistrationRepo(),
    );
  });
  testWidgets('opens under review account status after registration submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.getRoute,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    await _completeVehicleAndContinue(tester);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Submit acceptance request'));
    await tester.tap(find.text('Submit acceptance request'));
    await tester.pumpAndSettle();

    expect(find.text('Your account is under review'), findsOneWidget);
    expect(find.text('Review order'), findsNothing);
  });
}

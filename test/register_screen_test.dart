import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/widget/custom_app_bar.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/registration_step_progress.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_nationalities_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_restaurants_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_colors_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_types_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/resubmit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/search_driver_vehicle_models_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/submit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/upload_driver_document_usecase.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_event.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_view_model.dart';
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

class _TestRegistrationRepo implements DriverRegistrationRepository {
  int vehicleTypeLoadCount = 0;
  int vehicleColorLoadCount = 0;

  @override
  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities() async =>
      ApiSuccessResult(
        data: const [
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
        ],
      );

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async =>
      ApiSuccessResult(
        data: const [
          DriverRestaurantEntity(
            id: 'res-1',
            tradeName: 'Balance Box',
            tradeNameAr: 'بالانس بوكس',
            tradeNameEn: 'Balance Box',
          ),
        ],
      );

  @override
  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes() async {
    vehicleTypeLoadCount++;
    return ApiSuccessResult(
      data: const [
        DriverVehicleTypeEntity(
          code: 'Car',
          nameAr: 'سيارة',
          nameEn: 'Passenger car',
          iconKey: 'car',
        ),
      ],
    );
  }

  @override
  Future<ApiResult<List<DriverVehicleColorEntity>>> getVehicleColors() async {
    vehicleColorLoadCount++;
    return ApiSuccessResult(
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
  }

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

class _ErrorRegistrationRepo extends _TestRegistrationRepo {
  @override
  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities() async =>
      ApiErrorResult(failure: Failure(errorMessage: 'Temporary failure'));

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async =>
      ApiErrorResult(failure: Failure(errorMessage: 'Temporary failure'));
}

class _VehicleCatalogFailureRepo extends _TestRegistrationRepo {
  @override
  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes() async =>
      ApiErrorResult(failure: Failure(errorMessage: 'Vehicle types failed'));
}

Future<void> _completePersonalAndContinue(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final initialFields = find.byType(TextFormField);
  await tester.ensureVisible(initialFields.at(0));
  await tester.tap(initialFields.at(0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Balance Box').last);
  await tester.pumpAndSettle();

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(1), 'Ahmed Arabic Name');
  await tester.enterText(fields.at(2), 'Ahmed Mohamed Al-Shammari');
  await tester.enterText(fields.at(3), '+966501234567');
  await tester.enterText(fields.at(7), '1234567890');

  await tester.ensureVisible(fields.at(6));
  await tester.tap(fields.at(6));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Kuwaiti').last);
  await tester.pumpAndSettle();

  final updatedFields = find.byType(TextFormField);
  await tester.ensureVisible(updatedFields.at(8));
  await tester.tap(updatedFields.at(8));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(AppButton).last);
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  if (find.text('Choose vehicle type').evaluate().isEmpty) {
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data)
        .whereType<String>()
        .where(
          (text) => text.contains('required') || text.contains('not valid'),
        )
        .join(' | ');
    fail('Personal form did not advance: $texts');
  }
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

  testWidgets(
    'starts with personal data fields as the first registration step',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: const RegisterScreen(),
        ),
      );

      expect(find.byType(CustomAppBar), findsOneWidget);
      expect(find.text('Personal data'), findsWidgets);
      expect(find.text('Enter full name in Arabic'), findsOneWidget);
      expect(find.text('Enter full name in English'), findsOneWidget);
      expect(find.text('Choose restaurant'), findsOneWidget);
      expect(find.text('Enter phone number'), findsOneWidget);
      expect(find.text('Enter email (optional)'), findsOneWidget);
      expect(find.text('Choose birth date'), findsOneWidget);
      expect(find.text('Choose nationality'), findsOneWidget);
      expect(find.text('Enter civil ID'), findsOneWidget);
      expect(find.text('Choose ID expiry date'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Uploaded documents'), findsNothing);
    },
  );

  testWidgets(
    'loads vehicle catalogs once when the registration screen starts',
    (tester) async {
      final repository = _TestRegistrationRepo();
      final viewModel = DriverRegistrationViewModel(
        getRestaurantsUseCase: GetDriverRestaurantsUseCase(repository),
        getNationalitiesUseCase: GetDriverNationalitiesUseCase(repository),
        getVehicleTypesUseCase: GetDriverVehicleTypesUseCase(repository),
        getVehicleColorsUseCase: GetDriverVehicleColorsUseCase(repository),
        searchVehicleModelsUseCase: SearchDriverVehicleModelsUseCase(
          repository,
        ),
        uploadDocumentUseCase: UploadDriverDocumentUseCase(repository),
        submitRegistrationUseCase: SubmitDriverRegistrationUseCase(repository),
        resubmitRegistrationUseCase: ResubmitDriverRegistrationUseCase(
          repository,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: RegisterScreen(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.vehicleTypeLoadCount, 1);
      expect(repository.vehicleColorLoadCount, 1);

      await viewModel.close();
    },
  );

  testWidgets('shows vehicle catalog failures on the vehicle step', (
    tester,
  ) async {
    final repository = _VehicleCatalogFailureRepo();
    final viewModel = DriverRegistrationViewModel(
      getRestaurantsUseCase: GetDriverRestaurantsUseCase(repository),
      getNationalitiesUseCase: GetDriverNationalitiesUseCase(repository),
      getVehicleTypesUseCase: GetDriverVehicleTypesUseCase(repository),
      getVehicleColorsUseCase: GetDriverVehicleColorsUseCase(repository),
      searchVehicleModelsUseCase: SearchDriverVehicleModelsUseCase(repository),
      uploadDocumentUseCase: UploadDriverDocumentUseCase(repository),
      submitRegistrationUseCase: SubmitDriverRegistrationUseCase(repository),
      resubmitRegistrationUseCase: ResubmitDriverRegistrationUseCase(
        repository,
      ),
    );
    viewModel.doIntent(const DriverRegistrationStepChangedEvent(2));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: RegisterScreen(viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vehicle types failed'), findsOneWidget);

    await viewModel.close();
  });

  testWidgets('does not continue when required personal data is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Personal data'), findsWidgets);
    expect(find.text('Choose vehicle type'), findsNothing);
  });

  testWidgets('shows vehicle data as the second registration step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    expect(find.text('Vehicle data'), findsWidgets);
    expect(find.text('Choose vehicle type'), findsOneWidget);
    expect(find.text('Choose company / model'), findsOneWidget);
    expect(find.text('Choose manufacture year'), findsOneWidget);
    expect(find.text('Enter plate number'), findsOneWidget);
    expect(find.text('Do you own the vehicle?'), findsOneWidget);
    expect(find.text('Uploaded documents'), findsNothing);
  });

  testWidgets('uses app buttons for registration actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    expect(find.widgetWithText(AppButton, 'Continue'), findsOneWidget);

    await _completePersonalAndContinue(tester);

    expect(find.widgetWithText(AppButton, 'Continue'), findsOneWidget);

    await _completeVehicleAndContinue(tester);

    expect(find.widgetWithText(AppButton, 'Continue'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppButton, 'Edit'), findsNWidgets(3));
    expect(
      find.widgetWithText(AppButton, 'Submit acceptance request'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppButton, 'Back to edit'), findsOneWidget);
  });

  testWidgets('keeps registration progress outside the scrollable content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    expect(
      find.ancestor(
        of: find.byType(RegistrationStepProgress),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
  });

  testWidgets('app bar back button returns to the previous registration step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Personal data'), findsWidgets);
    expect(find.text('Enter full name in Arabic'), findsOneWidget);
    expect(find.text('Choose vehicle type'), findsNothing);
  });

  testWidgets('app bar back button returns from review to documents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    await _completeVehicleAndContinue(tester);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Documents'), findsWidgets);
    expect(find.text('Civil card'), findsOneWidget);
    expect(find.text('Back to edit'), findsNothing);
  });

  testWidgets('shows upload documents as the third registration step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    await _completeVehicleAndContinue(tester);

    expect(find.text('Documents'), findsWidgets);
    expect(find.text('Civil card'), findsOneWidget);
    expect(find.text('Clear photo of a valid civil card'), findsOneWidget);
    expect(find.text('Driving license'), findsOneWidget);
    expect(find.text('Clear photo of a valid driving license'), findsOneWidget);
    expect(find.text('Car registration'), findsOneWidget);
    expect(find.text('Front side of the car registration'), findsOneWidget);
    expect(find.text('Vehicle photo'), findsOneWidget);
    expect(find.text('Clear exterior photo of the vehicle'), findsOneWidget);
    expect(find.text('Personal photo'), findsOneWidget);
    expect(find.text('Personal photo with clear background'), findsOneWidget);
    expect(find.text('Important note'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Uploaded documents'), findsNothing);
  });

  testWidgets('renders review sections after submitting documents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    await _completeVehicleAndContinue(tester);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Review order'), findsWidgets);
    expect(find.text('Personal data'), findsWidgets);
    expect(find.text('Vehicle data'), findsWidgets);
    expect(find.text('Uploaded documents'), findsOneWidget);
    expect(find.text('Submit acceptance request'), findsOneWidget);
    expect(find.text('Back to edit'), findsOneWidget);
  });

  testWidgets('opens camera and gallery choices for photo upload', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    await _completeVehicleAndContinue(tester);

    await tester.ensureVisible(find.text('Personal photo'));
    await tester.tap(find.text('Personal photo'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('opens camera and gallery choices from review documents', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: const RegisterScreen(),
      ),
    );

    await _completePersonalAndContinue(tester);

    await _completeVehicleAndContinue(tester);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Personal photo'));
    await tester.tap(find.text('Personal photo'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('shows registration errors inline without a duplicate toast', (
    tester,
  ) async {
    final repository = _ErrorRegistrationRepo();
    final viewModel = DriverRegistrationViewModel(
      getRestaurantsUseCase: GetDriverRestaurantsUseCase(repository),
      getNationalitiesUseCase: GetDriverNationalitiesUseCase(repository),
      getVehicleTypesUseCase: GetDriverVehicleTypesUseCase(repository),
      getVehicleColorsUseCase: GetDriverVehicleColorsUseCase(repository),
      searchVehicleModelsUseCase: SearchDriverVehicleModelsUseCase(repository),
      uploadDocumentUseCase: UploadDriverDocumentUseCase(repository),
      submitRegistrationUseCase: SubmitDriverRegistrationUseCase(repository),
      resubmitRegistrationUseCase: ResubmitDriverRegistrationUseCase(
        repository,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: RegisterScreen(viewModel: viewModel),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Temporary failure'), findsOneWidget);

    await viewModel.close();
  });
}

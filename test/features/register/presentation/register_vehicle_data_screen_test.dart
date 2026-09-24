import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_color_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_model_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_type_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/register_vehicle_data.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_vehicle_data_screen.dart';
import 'package:meal_mate_delivery/features/register/presentation/widgets/register_vehicle_catalog_shimmer.dart';
import 'package:meal_mate_delivery/features/register/presentation/widgets/register_vehicle_color_picker.dart';

const _types = [
  DriverVehicleTypeEntity(
    code: 'Car',
    nameAr: 'سيارة',
    nameEn: 'Passenger car',
    iconKey: 'car',
  ),
  DriverVehicleTypeEntity(
    code: 'Motorcycle',
    nameAr: 'دراجة نارية',
    nameEn: 'Motorcycle',
    iconKey: 'motorcycle',
  ),
  DriverVehicleTypeEntity(
    code: '',
    nameAr: 'تجاهل',
    nameEn: 'Ignored empty code',
    iconKey: 'car',
  ),
];

const _colors = [
  DriverVehicleColorEntity(
    hex: '#5e35b1',
    nameAr: 'بنفسجي',
    nameEn: 'Purple',
    isDefault: true,
    displayOrder: 2,
  ),
  DriverVehicleColorEntity(
    hex: '#112233',
    nameAr: 'كحلي',
    nameEn: 'Navy',
    isDefault: true,
    displayOrder: 1,
  ),
  DriverVehicleColorEntity(
    hex: 'not-a-color',
    nameAr: 'غير صالح',
    nameEn: 'Malformed',
    isDefault: true,
    displayOrder: 0,
  ),
];

const _models = [
  DriverVehicleModelEntity(
    value: 'TOYOTA_CAMRY',
    makeCode: 'TOYOTA',
    makeNameAr: 'تويوتا',
    makeNameEn: 'Toyota',
    modelCode: 'CAMRY',
    modelNameAr: 'كامري',
    modelNameEn: 'Camry',
    fullNameAr: 'تويوتا كامري',
    fullNameEn: 'Toyota Camry',
    vehicleType: 'Car',
  ),
];

const _validData = RegisterVehicleData(
  type: 'Car',
  model: 'Free-form model',
  manufactureYear: '2026',
  plateNumber: '54821',
  country: 'Kuwait',
  color: '#112233',
  isOwned: true,
  licenseNumber: 'DL-839201',
  licenseExpiry: '2099-01-02T00:00:00.000',
  vehicleLicenseExpiry: '2099-01-03T00:00:00.000',
);

Widget _app({
  RegisterVehicleData initialData = _validData,
  List<DriverVehicleTypeEntity> types = _types,
  List<DriverVehicleColorEntity> colors = _colors,
  List<DriverVehicleModelEntity> models = const [],
  bool isLoadingVehicleTypes = false,
  bool isLoadingVehicleColors = false,
  bool isSearchingVehicleModels = false,
  ValueChanged<RegisterVehicleData>? onVehicleDataChanged,
  void Function(String search, String? vehicleType)? onModelSearch,
  void Function(String search, String? vehicleType)? onModelQueryChanged,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    home: RegisterVehicleDataScreen(
      initialData: initialData,
      vehicleTypes: types,
      vehicleColors: colors,
      vehicleModels: models,
      isLoadingVehicleTypes: isLoadingVehicleTypes,
      isLoadingVehicleColors: isLoadingVehicleColors,
      isSearchingVehicleModels: isSearchingVehicleModels,
      selectedVehicleColor: const Color(0xFF112233),
      ownsVehicle: initialData.isOwned,
      onColorSelected: (_) {},
      onOwnsVehicleChanged: (_) {},
      onSearchVehicleModels: onModelSearch,
      onVehicleModelQueryChanged: onModelQueryChanged,
      onVehicleDataChanged: onVehicleDataChanged,
      onContinue: () {},
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .views
        .first
        .physicalSize = const Size(
      1080,
      2400,
    );
    TestWidgetsFlutterBinding
            .instance
            .platformDispatcher
            .views
            .first
            .devicePixelRatio =
        1.0;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
        .resetPhysicalSize();
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
        .resetDevicePixelRatio();
  });

  testWidgets(
    'renders RegisterVehicleCatalogShimmer and no linear indicator when catalogs loading',
    (tester) async {
      await tester.pumpWidget(
        _app(isLoadingVehicleTypes: true, isLoadingVehicleColors: false),
      );
      await tester.pump();

      expect(find.byType(RegisterVehicleCatalogShimmer), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'renders compact ShimmerWidget and no linear indicator when searching models',
    (tester) async {
      await tester.pumpWidget(_app(isSearchingVehicleModels: true));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(ShimmerWidget), findsWidgets);
    },
  );
  testWidgets(
    'vehicle type displays localized label and submits backend code',
    (tester) async {
      RegisterVehicleData? submittedData;
      await tester.pumpWidget(
        _app(
          initialData: _validData.copyWith(type: ''),
          onVehicleDataChanged: (data) => submittedData = data,
        ),
      );

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();
      expect(find.text('Passenger car'), findsOneWidget);
      expect(find.text('Ignored empty code'), findsNothing);
      await tester.tap(find.text('Passenger car'));
      await tester.pumpAndSettle();
      expect(find.text('Passenger car'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Free-form model',
      );

      await tester.ensureVisible(find.byType(AppButton));
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(submittedData?.type, 'Car');
    },
  );

  testWidgets('model search waits 300 ms and forwards exact term and type', (
    tester,
  ) async {
    final searches = <(String, String?)>[];
    await tester.pumpWidget(
      _app(onModelSearch: (term, type) => searches.add((term, type))),
    );

    await tester.enterText(find.byType(TextFormField).at(1), 'Cam');
    await tester.pump(const Duration(milliseconds: 299));
    expect(searches, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(searches, [('Cam', 'Car')]);
  });

  testWidgets('rapid model typing searches only the latest exact query', (
    tester,
  ) async {
    final queries = <(String, String?)>[];
    final searches = <(String, String?)>[];
    await tester.pumpWidget(
      _app(
        models: _models,
        onModelQueryChanged: (term, type) => queries.add((term, type)),
        onModelSearch: (term, type) => searches.add((term, type)),
      ),
    );

    final modelField = find.byType(TextFormField).at(1);
    await tester.enterText(modelField, 'C');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(modelField, 'Ca');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(modelField, 'Cam');

    expect(queries, [('C', 'Car'), ('Ca', 'Car'), ('Cam', 'Car')]);
    expect(find.text('Toyota Camry'), findsNothing);
    await tester.pump(const Duration(milliseconds: 299));
    expect(searches, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(searches, [('Cam', 'Car')]);
  });

  testWidgets(
    'type switch cancels pending model search and clears suggestions',
    (tester) async {
      final queries = <(String, String?)>[];
      final searches = <(String, String?)>[];
      await tester.pumpWidget(
        _app(
          models: _models,
          onModelQueryChanged: (term, type) => queries.add((term, type)),
          onModelSearch: (term, type) => searches.add((term, type)),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(1), 'Cam');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Motorcycle'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));

      expect(searches, isEmpty);
      expect(queries.last, ('', 'Motorcycle'));
      expect(find.text('Toyota Camry'), findsNothing);
    },
  );

  testWidgets('model result displays localized name and submits exact value', (
    tester,
  ) async {
    RegisterVehicleData? submittedData;
    await tester.pumpWidget(
      _app(
        models: _models,
        onVehicleDataChanged: (data) => submittedData = data,
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(1), 'Cam');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Toyota Camry'));
    await tester.pump();
    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(submittedData?.model, 'TOYOTA_CAMRY');
  });

  testWidgets('backend color is ordered, canonicalized, and excludes alpha', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: RegisterVehicleColorPicker(
            colors: _colors,
            selectedHex: '',
            onColorSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Malformed'), findsNothing);
    final navy = find.bySemanticsLabel('Navy');
    final purple = find.bySemanticsLabel('Purple');
    expect(tester.getTopLeft(navy).dx, lessThan(tester.getTopLeft(purple).dx));
    await tester.tap(purple);
    expect(selected, '#5E35B1');
    expect(selected, isNot(startsWith('#FF')));
  });

  testWidgets('Other accepts labeled HEX input and returns canonical value', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: RegisterVehicleColorPicker(
            colors: _colors,
            selectedHex: '',
            onColorSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    final input = find.byKey(const ValueKey('vehicleColorHexInput'));
    expect(input, findsOneWidget);
    await tester.enterText(input, '5e35b1');
    await tester.pump();
    expect(find.byKey(const ValueKey('vehicleColorPreview')), findsOneWidget);
    await tester.tap(find.text('Use color'));
    await tester.pumpAndSettle();
    expect(selected, '#5E35B1');
  });

  testWidgets('custom selected color keeps a named selected preview', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: RegisterVehicleColorPicker(
            colors: _colors,
            selectedHex: '#ABCDEF',
            onColorSelected: _ignoreColor,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Other #ABCDEF'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('selectedCustomVehicleColorPreview')),
      findsOneWidget,
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('selectedCustomVehicleColorPreview')),
          )
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    semantics.dispose();
  });

  testWidgets(
    'entered plate and license survive color and ownership rebuilds',
    (tester) async {
      RegisterVehicleData? submittedData;
      var color = const Color(0xFF112233);
      var owns = true;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) => RegisterVehicleDataScreen(
              initialData: _validData.copyWith(
                plateNumber: '',
                licenseNumber: '',
              ),
              vehicleTypes: _types,
              vehicleColors: _colors,
              vehicleModels: const [],
              selectedVehicleColor: color,
              ownsVehicle: owns,
              onColorSelected: (next) => setState(() => color = next),
              onOwnsVehicleChanged: (next) => setState(() => owns = next),
              onVehicleDataChanged: (data) => submittedData = data,
              onContinue: () {},
            ),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(3), '54821');
      await tester.enterText(fields.at(4), 'DL-839201');
      await tester.ensureVisible(find.bySemanticsLabel('Purple'));
      await tester.tap(find.bySemanticsLabel('Purple'));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('No'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
      await tester.pump();
      await tester.tap(find.text('No'));
      await tester.pump();
      expect(find.text('54821'), findsOneWidget);
      expect(find.text('DL-839201'), findsOneWidget);
      await tester.ensureVisible(find.byType(AppButton));
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(submittedData?.plateNumber, '54821');
      expect(submittedData?.licenseNumber, 'DL-839201');
      expect(submittedData?.isOwned, isFalse);
    },
  );

  testWidgets('blank and past required expiry dates block continuation', (
    tester,
  ) async {
    RegisterVehicleData? submittedData;
    await tester.pumpWidget(
      _app(
        initialData: _validData.copyWith(
          licenseExpiry: '',
          vehicleLicenseExpiry: '2000-01-01T00:00:00.000',
        ),
        onVehicleDataChanged: (data) => submittedData = data,
      ),
    );

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(submittedData, isNull);
    expect(find.text('This field is required'), findsOneWidget);
    expect(find.text('Date must be in the future'), findsOneWidget);
  });

  testWidgets('blank contract maps to null and valid dates stay ISO 8601', (
    tester,
  ) async {
    RegisterVehicleData? submittedData;
    await tester.pumpWidget(
      _app(onVehicleDataChanged: (data) => submittedData = data),
    );

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(submittedData?.contractExpiry, isNull);
    expect(DateTime.tryParse(submittedData?.licenseExpiry ?? ''), isNotNull);
    expect(
      DateTime.tryParse(submittedData?.vehicleLicenseExpiry ?? ''),
      isNotNull,
    );
  });

  testWidgets('existing optional contract can be cleared and submits null', (
    tester,
  ) async {
    RegisterVehicleData? submittedData;
    await tester.pumpWidget(
      _app(
        initialData: _validData.copyWith(
          contractExpiry: '2099-01-04T00:00:00.000',
        ),
        onVehicleDataChanged: (data) => submittedData = data,
      ),
    );

    final clearAction = find.byTooltip('Clear contract expiry');
    await tester.ensureVisible(clearAction);
    await tester.tap(clearAction);
    await tester.pump();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(7))
          .controller
          ?.text,
      isEmpty,
    );
    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(submittedData?.contractExpiry, isNull);
  });

  testWidgets('manufacturing year outside 1990 through next year is rejected', (
    tester,
  ) async {
    RegisterVehicleData? submittedData;
    await tester.pumpWidget(
      _app(
        initialData: _validData.copyWith(manufactureYear: '1989'),
        onVehicleDataChanged: (data) => submittedData = data,
      ),
    );

    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(submittedData, isNull);
    expect(find.textContaining('Enter a year from 1990'), findsOneWidget);
  });
}

void _ignoreColor(String _) {}

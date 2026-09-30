import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_profile_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/repo/driver_profile_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/usecase/get_driver_profile_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/manager/driver_profile_view_model.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/screens/driver_profile_screen.dart';

class _FakeProfileRepository implements DriverProfileRepository {
  Future<ApiResult<DriverProfileEntity>> Function()? handler;
  int callCount = 0;

  @override
  Future<ApiResult<DriverProfileEntity>> getProfile() async {
    callCount++;
    if (handler != null) {
      return handler!();
    }
    return const ApiSuccessResult(data: _testProfile);
  }
}

const _testProfile = DriverProfileEntity(
  driverProfileId: 'drv-perf-1',
  fullName: 'سائق الأداء',
  driverDescription: 'سائق للاختبار',
  driverCode: 'DRV-PERF',
  isOnline: true,
  status: 'Active',
  statusText: 'نشط',
  reviewsCount: 5,
  totalOrders: 20,
);

class _TestHostWidget extends StatefulWidget {
  const _TestHostWidget({
    required this.viewModel,
    this.isActive = true,
    this.locale = const Locale('ar'),
    this.unrelatedCounter = 0,
  });

  final DriverProfileViewModel viewModel;
  final bool isActive;
  final Locale locale;
  final int unrelatedCounter;

  @override
  State<_TestHostWidget> createState() => _TestHostWidgetState();
}

class _TestHostWidgetState extends State<_TestHostWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: widget.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: Column(
        children: [
          Text('Counter: ${widget.unrelatedCounter}'),
          Expanded(
            child: DriverProfileScreen(
              viewModel: widget.viewModel,
              isActive: widget.isActive,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  late _FakeProfileRepository repository;
  late GetDriverProfileUseCase useCase;
  late DriverProfileViewModel viewModel;

  setUp(() {
    repository = _FakeProfileRepository();
    useCase = GetDriverProfileUseCase(repository);
    viewModel = DriverProfileViewModel(getDriverProfileUseCase: useCase);
  });

  tearDown(() async {
    await viewModel.close();
  });

  testWidgets('unrelated parent rebuilds do not refetch profile', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        unrelatedCounter: 0,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.callCount, equals(1));
    expect(find.text('سائق الأداء'), findsOneWidget);

    // Rebuild parent with updated counter (simulating parent state changes)
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        unrelatedCounter: 1,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Counter: 1'), findsOneWidget);
    // Request count MUST NOT increase
    expect(repository.callCount, equals(1));

    // Another rebuild
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        unrelatedCounter: 2,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Counter: 2'), findsOneWidget);
    expect(repository.callCount, equals(1));
  });

  testWidgets('reactivation inside freshness window does not refetch', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        isActive: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.callCount, equals(1));

    // Deactivate tab
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        isActive: false,
      ),
    );
    await tester.pump();

    // Reactivate tab within 15 minutes
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        isActive: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Inside freshness window, no second network call
    expect(repository.callCount, equals(1));
  });

  testWidgets('reactivation outside freshness window triggers exactly one refetch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        isActive: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.callCount, equals(1));

    // Deactivate tab
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        isActive: false,
      ),
    );
    await tester.pump();

    // Age the cache by 16 minutes (beyond 15-min freshness threshold)
    viewModel.emit(
      viewModel.state.copyWith(
        lastSuccessfulLoadAt: DateTime.now().toUtc().subtract(
              const Duration(minutes: 16),
            ),
      ),
    );

    // Reactivate tab
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        isActive: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Stale cache triggers exactly 1 refetch: callCount becomes 2
    expect(repository.callCount, equals(2));
  });

  testWidgets('one locale change causes exactly one new request', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        locale: const Locale('ar'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(repository.callCount, equals(1));

    // Switch locale to English
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        locale: const Locale('en'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Exactly one new request was issued
    expect(repository.callCount, equals(2));

    // Another rebuild with the same English locale does NOT issue another request
    await tester.pumpWidget(
      _TestHostWidget(
        viewModel: viewModel,
        locale: const Locale('en'),
        unrelatedCounter: 42,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.callCount, equals(2));
  });
}

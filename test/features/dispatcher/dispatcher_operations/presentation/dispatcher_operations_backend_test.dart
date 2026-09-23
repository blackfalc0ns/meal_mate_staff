import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_item_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_counters_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_customer_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_page_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/usecase/get_operations_log_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/screens/dispatcher_operations_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/dispatcher_operations_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_cards_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_empty_state.dart';

class FakeScreenOperationsRepository implements OperationsLogRepository {
  ApiResult<OperationsPageEntity> result = const ApiSuccessResult(
    data: OperationsPageEntity(
      counters: OperationsCountersEntity(allCount: 1),
      operations: [
        OperationItemEntity(
          id: 'op-1',
          boxId: '3fa85f64-5717-4562-b3fc-2c963f66afa2',
          boxCode: '#BX-10256',
          status: OperationStatus.completed,
          customer: OperationsCustomerEntity(
            id: 'c-1',
            name: 'شهد المطيري',
            area: 'حي الملقا',
            addressText: 'حي الملقا',
          ),
          timeText: '10:45 ص',
          driver: OperationsDriverEntity(id: 'd-1', name: 'يوسف خالد'),
        ),
      ],
      pagination: OperationsPaginationEntity(
        pageNumber: 1,
        pageSize: 10,
        totalItems: 1,
        totalPages: 1,
        hasPreviousPage: false,
        hasNextPage: false,
      ),
    ),
  );

  int callCount = 0;
  OperationsQueryEntity? lastQuery;
  Duration delay = Duration.zero;

  @override
  Future<ApiResult<OperationsPageEntity>> getOperations(
    OperationsQueryEntity query,
  ) async {
    callCount++;
    lastQuery = query;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result;
  }
}

Widget createScreenTestWidget({
  required OperationsViewModel viewModel,
  ValueChanged<String>? onOpenBoxTracking,
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
    home: DispatcherOperationsScreen(
      viewModel: viewModel,
      onOpenBoxTracking: onOpenBoxTracking,
    ),
  );
}

void main() {
  late FakeScreenOperationsRepository repository;
  late GetOperationsLogUseCase useCase;
  late OperationsViewModel viewModel;

  setUp(() {
    repository = FakeScreenOperationsRepository();
    useCase = GetOperationsLogUseCase(repository);
    viewModel = OperationsViewModel(
      getOperationsLogUseCase: useCase,
      searchDebounceDuration: const Duration(milliseconds: 100),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('DispatcherOperationsScreen Integration', () {
    testWidgets(
      'first frame triggers load, renders shimmer, then loaded response',
      (tester) async {
        repository.delay = const Duration(milliseconds: 200);

        await tester.pumpWidget(createScreenTestWidget(viewModel: viewModel));
        // First frame before delay finishes
        await tester.pump();
        expect(find.byType(DispatcherOperationsShimmer), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 250));
        await tester.pumpAndSettle();

        expect(find.byType(DispatcherOperationsShimmer), findsNothing);
        expect(find.text('#BX-10256'), findsOneWidget);
        expect(find.text('يوسف خالد'), findsOneWidget);
      },
    );

    testWidgets(
      'initial typed failure renders ApiErrorWidget and retry succeeds',
      (tester) async {
        repository.result = ApiErrorResult(
          failure: Failure(errorMessage: 'Connection lost'),
        );

        await tester.pumpWidget(createScreenTestWidget(viewModel: viewModel));
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsOneWidget);

        // Now set success and retry
        repository.result = const ApiSuccessResult(
          data: OperationsPageEntity(
            counters: OperationsCountersEntity(allCount: 1),
            operations: [
              OperationItemEntity(
                id: 'op-1',
                boxId: 'bx-1',
                boxCode: '#BX-10256',
                status: OperationStatus.completed,
                customer: OperationsCustomerEntity(
                  id: 'c-1',
                  name: 'شهد',
                  area: 'الملقا',
                  addressText: 'الملقا',
                ),
                timeText: '10:00 ص',
              ),
            ],
            pagination: OperationsPaginationEntity(),
          ),
        );

        await tester.tap(find.text('إعادة المحاولة'));
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsNothing);
        expect(find.text('#BX-10256'), findsOneWidget);
      },
    );

    testWidgets('successful empty response renders OperationsEmptyState', (
      tester,
    ) async {
      repository.result = const ApiSuccessResult(
        data: OperationsPageEntity(
          counters: OperationsCountersEntity(allCount: 0),
          operations: [],
          pagination: OperationsPaginationEntity(totalItems: 0, totalPages: 0),
        ),
      );

      await tester.pumpWidget(createScreenTestWidget(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(OperationsEmptyState), findsOneWidget);
    });

    testWidgets(
      'tapping card emits raw boxId to onOpenBoxTracking without fake timeline',
      (tester) async {
        String? openedBoxId;

        await tester.pumpWidget(
          createScreenTestWidget(
            viewModel: viewModel,
            onOpenBoxTracking: (boxId) => openedBoxId = boxId,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('#BX-10256'));
        expect(openedBoxId, '3fa85f64-5717-4562-b3fc-2c963f66afa2');
      },
    );

    testWidgets(
      'replacement loading preserves header and shows OperationsCardsShimmer',
      (tester) async {
        await tester.pumpWidget(createScreenTestWidget(viewModel: viewModel));
        await tester.pumpAndSettle();
        expect(find.text('#BX-10256'), findsOneWidget);

        // Trigger replacement with delay
        repository.delay = const Duration(milliseconds: 300);
        await tester.tap(find.text('معاد إسنادها'));
        await tester.pump();

        // Controls stay, cards shimmer appears!
        expect(find.byType(OperationsCardsShimmer), findsOneWidget);
        expect(find.text('معاد إسنادها'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();

        expect(find.byType(OperationsCardsShimmer), findsNothing);
      },
    );

    testWidgets('nonfatal failure retains previous data and shows snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(createScreenTestWidget(viewModel: viewModel));
      await tester.pumpAndSettle();
      expect(find.text('#BX-10256'), findsOneWidget);

      repository.result = ApiErrorResult(
        failure: Failure(errorMessage: 'Replacement network failure'),
      );

      await tester.tap(find.text('ملغاة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Data is retained
      expect(find.text('#BX-10256'), findsOneWidget);
      // Toast / SnackBar with error message is displayed
      expect(find.text('Replacement network failure'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}

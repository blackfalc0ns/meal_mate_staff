import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/repo/assign_box_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_summary_usecase.dart';

class MockAssignBoxRepository implements AssignBoxRepository {
  int getDetailsCalls = 0;
  int getSummaryCalls = 0;
  String? lastDetailsBoxId;
  String? lastSummaryBoxId;

  ApiResult<AssignBoxDetailsEntity>? detailsResult;
  ApiResult<AssignBoxSummaryEntity>? summaryResult;

  @override
  Future<ApiResult<AssignBoxDetailsEntity>> getDetails(String boxId) async {
    getDetailsCalls++;
    lastDetailsBoxId = boxId;
    return detailsResult ??
        const ApiSuccessResult(
          data: AssignBoxDetailsEntity(
            box: AssignBoxOrderEntity(
              boxId: 'a1111111-1111-1111-1111-111111111111',
              boxCode: '#BX-1',
              zoneName: 'Zone',
              deliveryTimeWindow: '10:00',
              mealsCount: 1,
              mealsCountText: '1 meal',
              distanceText: '1 km',
              priority: AssignBoxPriority.normal,
              priorityText: 'Normal',
              status: AssignBoxStatus.pending,
              statusText: 'Pending',
            ),
            bestSuggestion: null,
            candidates: [],
          ),
        );
  }

  @override
  Future<ApiResult<AssignBoxSummaryEntity>> getSummary(String boxId) async {
    getSummaryCalls++;
    lastSummaryBoxId = boxId;
    return summaryResult ??
        const ApiSuccessResult(
          data: AssignBoxSummaryEntity(
            boxId: 'a1111111-1111-1111-1111-111111111111',
            boxCode: '#BX-1',
            boxCount: 1,
          ),
        );
  }
}

void main() {
  late MockAssignBoxRepository repository;
  late GetAssignBoxDetailsUseCase getDetailsUseCase;
  late GetAssignBoxSummaryUseCase getSummaryUseCase;

  setUp(() {
    repository = MockAssignBoxRepository();
    getDetailsUseCase = GetAssignBoxDetailsUseCase(repository);
    getSummaryUseCase = GetAssignBoxSummaryUseCase(repository);
  });

  group('GetAssignBoxDetailsUseCase', () {
    test('locally rejects empty box ID without calling repository', () async {
      final result = await getDetailsUseCase('');
      expect(result, isA<ApiErrorResult<AssignBoxDetailsEntity>>());
      final failure = (result as ApiErrorResult<AssignBoxDetailsEntity>).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(repository.getDetailsCalls, 0);
    });

    test('locally rejects non-GUID box ID without calling repository', () async {
      final result = await getDetailsUseCase('not-a-guid');
      expect(result, isA<ApiErrorResult<AssignBoxDetailsEntity>>());
      final failure = (result as ApiErrorResult<AssignBoxDetailsEntity>).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(repository.getDetailsCalls, 0);
    });

    test('calls repository when boxId is valid GUID', () async {
      const validId = 'a1111111-1111-1111-1111-111111111111';
      final result = await getDetailsUseCase(validId);

      expect(result, isA<ApiSuccessResult<AssignBoxDetailsEntity>>());
      expect(repository.getDetailsCalls, 1);
      expect(repository.lastDetailsBoxId, validId);
    });
  });

  group('GetAssignBoxSummaryUseCase', () {
    test('locally rejects empty box ID without calling repository', () async {
      final result = await getSummaryUseCase('   ');
      expect(result, isA<ApiErrorResult<AssignBoxSummaryEntity>>());
      final failure = (result as ApiErrorResult<AssignBoxSummaryEntity>).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(repository.getSummaryCalls, 0);
    });

    test('locally rejects non-GUID box ID without calling repository', () async {
      final result = await getSummaryUseCase('invalid-id-format');
      expect(result, isA<ApiErrorResult<AssignBoxSummaryEntity>>());
      final failure = (result as ApiErrorResult<AssignBoxSummaryEntity>).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(repository.getSummaryCalls, 0);
    });

    test('calls repository when boxId is valid GUID', () async {
      const validId = 'a1111111-1111-1111-1111-111111111111';
      final result = await getSummaryUseCase(validId);

      expect(result, isA<ApiSuccessResult<AssignBoxSummaryEntity>>());
      expect(repository.getSummaryCalls, 1);
      expect(repository.lastSummaryBoxId, validId);
    });
  });
}

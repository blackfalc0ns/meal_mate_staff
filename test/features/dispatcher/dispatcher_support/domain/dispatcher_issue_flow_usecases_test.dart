import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidates_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/resolve_issue_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_issue_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_replacement_driver_candidates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/reassign_dispatcher_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/resolve_dispatcher_issue_usecase.dart';

class FakeDispatcherSupportRepository implements DispatcherSupportRepository {
  String? lastIssueId;
  String? lastNotes;
  int? lastPageNumber;
  int? lastPageSize;
  ReassignDriverRequestEntity? lastReassignRequest;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<ApiResult<DispatcherIssueDetailEntity>> getIssueDetails(String issueId) async {
    lastIssueId = issueId;
    return const ApiSuccessResult(
      data: DispatcherIssueDetailEntity(
        issueId: 'iss-1',
        title: 'تفاصيل البلاغ',
        boxCode: 'BX-1',
        area: 'حي الملز',
      ),
    );
  }

  @override
  Future<ApiResult<ResolveIssueResultEntity>> resolveIssue(
    String issueId,
    String resolutionNotes,
  ) async {
    lastIssueId = issueId;
    lastNotes = resolutionNotes;
    return const ApiSuccessResult(
      data: ResolveIssueResultEntity(
        issueId: 'iss-1',
        status: DispatcherIssueStatus.resolved,
      ),
    );
  }

  @override
  Future<ApiResult<ReassignDriverCandidatesEntity>> getReplacementCandidates(
    String issueId, {
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    lastIssueId = issueId;
    lastPageNumber = pageNumber;
    lastPageSize = pageSize;
    return const ApiSuccessResult(
      data: ReassignDriverCandidatesEntity(
        summary: ReassignDriverIssueSummaryEntity(
          issueId: 'iss-1',
          title: 'ملخص',
        ),
      ),
    );
  }

  @override
  Future<ApiResult<ReassignmentResultEntity>> reassignIssue(
    String issueId,
    ReassignDriverRequestEntity request,
  ) async {
    lastIssueId = issueId;
    lastReassignRequest = request;
    return const ApiSuccessResult(
      data: ReassignmentResultEntity(
        issueId: 'iss-1',
        status: DispatcherIssueStatus.resolved,
      ),
    );
  }
}

void main() {
  late FakeDispatcherSupportRepository repository;
  late GetDispatcherIssueDetailsUseCase getIssueDetailsUseCase;
  late ResolveDispatcherIssueUseCase resolveIssueUseCase;
  late GetReplacementDriverCandidatesUseCase getCandidatesUseCase;
  late ReassignDispatcherIssueUseCase reassignUseCase;

  setUp(() {
    repository = FakeDispatcherSupportRepository();
    getIssueDetailsUseCase = GetDispatcherIssueDetailsUseCase(repository);
    resolveIssueUseCase = ResolveDispatcherIssueUseCase(repository);
    getCandidatesUseCase = GetReplacementDriverCandidatesUseCase(repository);
    reassignUseCase = ReassignDispatcherIssueUseCase(repository);
  });

  group('Dispatcher Issue Workflow UseCases Tests', () {
    test('GetDispatcherIssueDetailsUseCase trims issueId and delegates', () async {
      final result = await getIssueDetailsUseCase('  iss-123  ');
      expect(repository.lastIssueId, 'iss-123');
      expect(result, isA<ApiSuccessResult<DispatcherIssueDetailEntity>>());
    });

    test('ResolveDispatcherIssueUseCase trims parameters and delegates', () async {
      final result = await resolveIssueUseCase(' iss-123 ', '  ملاحظات  ');
      expect(repository.lastIssueId, 'iss-123');
      expect(repository.lastNotes, 'ملاحظات');
      expect(result, isA<ApiSuccessResult<ResolveIssueResultEntity>>());
    });

    test('GetReplacementDriverCandidatesUseCase validates pagination before repo call', () async {
      // invalid pageNumber < 1
      final invalidPage = await getCandidatesUseCase('iss-123', pageNumber: 0);
      expect(invalidPage, isA<ApiErrorResult<ReassignDriverCandidatesEntity>>());
      expect(repository.lastIssueId, isNull);

      // invalid pageSize > 50
      final invalidSize = await getCandidatesUseCase('iss-123', pageSize: 51);
      expect(invalidSize, isA<ApiErrorResult<ReassignDriverCandidatesEntity>>());
      expect(repository.lastIssueId, isNull);

      // valid params
      final valid = await getCandidatesUseCase('iss-123', pageNumber: 2, pageSize: 25);
      expect(valid, isA<ApiSuccessResult<ReassignDriverCandidatesEntity>>());
      expect(repository.lastPageNumber, 2);
      expect(repository.lastPageSize, 25);
    });

    test('ReassignDispatcherIssueUseCase passes request to repository', () async {
      const request = ReassignDriverRequestEntity(
        replacementDriverId: 'driver-2',
        notes: null,
      );
      final result = await reassignUseCase('iss-123', request);
      expect(repository.lastIssueId, 'iss-123');
      expect(repository.lastReassignRequest?.replacementDriverId, 'driver-2');
      expect(result, isA<ApiSuccessResult<ReassignmentResultEntity>>());
    });
  });
}

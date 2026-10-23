import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/repo/driver_issue_repository.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/usecase/upload_driver_issue_evidence_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_add_photos_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_details_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/entities/driver_support_ticket_status.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/repo/driver_support_repository.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/usecase/add_driver_support_issue_photos_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/domain/usecase/get_driver_support_issue_details_usecase.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/manager/driver_support_ticket_details_event.dart';
import 'package:meal_mate_delivery/features/driver/driver_support_tickets/presentation/manager/driver_support_ticket_details_view_model.dart';

class MockDriverSupportDetailsRepository implements DriverSupportRepository {
  DriverSupportTicketDetailsEntity? mockDetailsResult;
  DriverSupportAddPhotosResultEntity? mockAddPhotosResult;
  Failure? mockFailure;
  Failure? mockAddPhotosFailure;
  List<String> lastAttachedKeys = [];
  int detailsCallCount = 0;

  @override
  Future<ApiResult<DriverSupportTicketDetailsEntity>> getSupportIssueDetails(
    String issueId,
  ) async {
    detailsCallCount++;
    if (mockFailure != null) {
      return ApiErrorResult(failure: mockFailure!);
    }
    return ApiSuccessResult(
      data:
          mockDetailsResult ??
          DriverSupportTicketDetailsEntity(
            issueId: issueId,
            category: 'Other',
            categoryLabel: 'أخرى',
            title: 'بلاغ تجريبي',
            status: DriverSupportTicketStatus.underReview,
            rawStatus: 'Submitted',
            statusLabel: 'قيد المراجعة',
          ),
    );
  }

  @override
  Future<ApiResult<DriverSupportAddPhotosResultEntity>> addSupportIssuePhotos(
    String issueId,
    List<String> storageKeys,
  ) async {
    lastAttachedKeys = List.from(storageKeys);
    if (mockAddPhotosFailure != null) {
      return ApiErrorResult(failure: mockAddPhotosFailure!);
    }
    return ApiSuccessResult(
      data:
          mockAddPhotosResult ??
          DriverSupportAddPhotosResultEntity(
            issueId: issueId,
            status: DriverSupportTicketStatus.underReview,
            statusLabel: 'قيد المراجعة',
            evidenceUrls: storageKeys,
          ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDriverIssueEvidenceRepository implements DriverIssueRepository {
  String? mockUploadedKey = 'uploaded/key.jpg';
  Failure? mockUploadFailure;
  int uploadCallCount = 0;

  @override
  Future<ApiResult<String>> uploadEvidence(File file) async {
    uploadCallCount++;
    if (mockUploadFailure != null) {
      return ApiErrorResult(failure: mockUploadFailure!);
    }
    return ApiSuccessResult(data: mockUploadedKey!);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockDriverSupportDetailsRepository detailsRepo;
  late MockDriverIssueEvidenceRepository uploadRepo;
  late DriverSupportTicketDetailsViewModel viewModel;

  setUp(() {
    detailsRepo = MockDriverSupportDetailsRepository();
    uploadRepo = MockDriverIssueEvidenceRepository();

    final getDetailsUseCase = GetDriverSupportIssueDetailsUseCase(detailsRepo);
    final addPhotosUseCase = AddDriverSupportIssuePhotosUseCase(detailsRepo);
    final uploadEvidenceUseCase = UploadDriverIssueEvidenceUseCase(uploadRepo);

    viewModel = DriverSupportTicketDetailsViewModel(
      getDriverSupportIssueDetailsUseCase: getDetailsUseCase,
      addDriverSupportIssuePhotosUseCase: addPhotosUseCase,
      uploadDriverIssueEvidenceUseCase: uploadEvidenceUseCase,
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  test(
    'image failures refresh once per read cycle without uploading',
    () async {
      viewModel.doIntent(
        const LoadDriverSupportTicketDetailsEvent('issue-100'),
      );
      await Future<void>.delayed(Duration.zero);
      for (var i = 0; i < 3; i++) {
        viewModel.doIntent(const RefreshSupportEvidenceUrlsEvent());
      }
      await Future<void>.delayed(Duration.zero);
      expect(detailsRepo.detailsCallCount, 2);
      viewModel.doIntent(const RefreshSupportEvidenceUrlsEvent());
      await Future<void>.delayed(Duration.zero);
      expect(detailsRepo.detailsCallCount, 2);
      expect(uploadRepo.uploadCallCount, 0);
      viewModel.doIntent(const RefreshDriverSupportTicketDetailsEvent());
      await Future<void>.delayed(Duration.zero);
      viewModel.doIntent(const RefreshSupportEvidenceUrlsEvent());
      await Future<void>.delayed(Duration.zero);
      expect(detailsRepo.detailsCallCount, 4);
    },
  );

  group('DriverSupportTicketDetailsViewModel', () {
    test(
      'LoadDriverSupportTicketDetailsEvent loads details successfully',
      () async {
        detailsRepo.mockDetailsResult = const DriverSupportTicketDetailsEntity(
          issueId: 'issue-100',
          category: 'VehicleBreakdown',
          categoryLabel: 'عطل سيارة',
          title: 'عطل إطار',
          status: DriverSupportTicketStatus.awaitingResponse,
          rawStatus: 'Submitted',
          statusLabel: 'بانتظار الرد',
          evidenceUrls: ['photo1.jpg'],
        );

        viewModel.doIntent(
          const LoadDriverSupportTicketDetailsEvent('issue-100'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.details, isNotNull);
        expect(viewModel.state.details!.issueId, equals('issue-100'));
        expect(viewModel.state.details!.evidenceUrls.length, equals(1));
        expect(viewModel.state.failure, isNull);
      },
    );

    test(
      'LoadDriverSupportTicketDetailsEvent with empty id emits failure',
      () async {
        viewModel.doIntent(const LoadDriverSupportTicketDetailsEvent('   '));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.failure, isNotNull);
        expect(
          viewModel.state.failure!.code,
          equals('DRIVER_SUPPORT_ISSUE_INVALID_ID'),
        );
      },
    );

    test(
      'AddDriverSupportTicketPhotoEvent prevents upload when issue is resolved',
      () async {
        detailsRepo.mockDetailsResult = const DriverSupportTicketDetailsEntity(
          issueId: 'issue-100',
          category: 'VehicleBreakdown',
          categoryLabel: 'عطل سيارة',
          title: 'عطل إطار',
          status: DriverSupportTicketStatus.resolved,
          rawStatus: 'Resolved',
          statusLabel: 'تم الحل',
        );

        viewModel.doIntent(
          const LoadDriverSupportTicketDetailsEvent('issue-100'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        viewModel.doIntent(AddDriverSupportTicketPhotoEvent(File('dummy.png')));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(uploadRepo.uploadCallCount, equals(0));
        expect(viewModel.state.actionFailure, isNotNull);
        expect(
          viewModel.state.actionFailure!.code,
          equals('DRIVER_SUPPORT_ISSUE_TERMINAL'),
        );
      },
    );

    test(
      'AddDriverSupportTicketPhotoEvent prevents upload when photo limit (3) is reached',
      () async {
        detailsRepo.mockDetailsResult = const DriverSupportTicketDetailsEntity(
          issueId: 'issue-100',
          category: 'VehicleBreakdown',
          categoryLabel: 'عطل سيارة',
          title: 'عطل إطار',
          status: DriverSupportTicketStatus.underReview,
          rawStatus: 'Submitted',
          statusLabel: 'قيد المراجعة',
          evidenceUrls: ['p1.jpg', 'p2.jpg', 'p3.jpg'],
        );

        viewModel.doIntent(
          const LoadDriverSupportTicketDetailsEvent('issue-100'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        viewModel.doIntent(AddDriverSupportTicketPhotoEvent(File('dummy.png')));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(uploadRepo.uploadCallCount, equals(0));
        expect(viewModel.state.actionFailure, isNotNull);
        expect(
          viewModel.state.actionFailure!.code,
          equals('DRIVER_SUPPORT_PHOTO_LIMIT'),
        );
      },
    );

    test(
      'AddDriverSupportTicketPhotoEvent uploads and attaches photo, retains key if attach fails',
      () async {
        // 1. Initial details with 1 photo
        detailsRepo.mockDetailsResult = const DriverSupportTicketDetailsEntity(
          issueId: 'issue-100',
          category: 'VehicleBreakdown',
          categoryLabel: 'عطل سيارة',
          title: 'عطل إطار',
          status: DriverSupportTicketStatus.underReview,
          rawStatus: 'Submitted',
          statusLabel: 'قيد المراجعة',
          evidenceUrls: ['p1.jpg'],
        );

        viewModel.doIntent(
          const LoadDriverSupportTicketDetailsEvent('issue-100'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // 2. Attach failure simulated
        detailsRepo.mockAddPhotosFailure = Failure(
          errorMessage: 'Attach failed',
          code: 'ATTACH_FAILED',
        );

        viewModel.doIntent(AddDriverSupportTicketPhotoEvent(File('new.png')));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Upload was called once
        expect(uploadRepo.uploadCallCount, equals(1));
        // Key was preserved in pendingStorageKeys for retry
        expect(
          viewModel.state.pendingStorageKeys,
          equals(['uploaded/key.jpg']),
        );
        expect(viewModel.state.actionFailure, isNotNull);

        // 3. Retry attach without re-uploading
        detailsRepo.mockAddPhotosFailure = null;
        viewModel.doIntent(const RetryAttachPhotosEvent());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Upload call count is STILL 1 (no re-upload!)
        expect(uploadRepo.uploadCallCount, equals(1));
        expect(detailsRepo.lastAttachedKeys, equals(['uploaded/key.jpg']));
        expect(viewModel.state.pendingStorageKeys, isEmpty);
        expect(viewModel.state.actionFailure, isNull);
      },
    );
  });
}

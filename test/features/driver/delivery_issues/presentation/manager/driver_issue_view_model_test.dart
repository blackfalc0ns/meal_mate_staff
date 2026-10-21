import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/issue_photo_item.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/repo/driver_issue_repository.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/usecase/report_driver_delay_usecase.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/usecase/report_driver_issue_usecase.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/usecase/upload_driver_issue_evidence_usecase.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/manager/driver_issue_event.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/manager/driver_issue_state.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/manager/driver_issue_view_model.dart';

class MockDriverIssueRepository implements DriverIssueRepository {
  ApiResult<String>? reportIssueResult;
  ApiResult<bool>? reportDelayResult;
  ApiResult<String>? uploadEvidenceResult;

  int reportIssueCallCount = 0;
  int uploadEvidenceCallCount = 0;

  Duration? reportIssueDelay;
  Duration? uploadEvidenceDelay;

  String? lastReportedBoxId;
  DeliveryIssueReason? lastReportedReason;
  String? lastReportedDescription;
  List<String>? lastReportedPhotoKeys;

  int? lastDelayMinutes;
  String? lastDelayReason;
  File? lastUploadedEvidenceFile;

  @override
  Future<ApiResult<String>> reportIssue({
    required String boxId,
    required DeliveryIssueReason reason,
    String? description,
    String? severity = 'Medium',
    List<String>? photoStorageKeys,
  }) async {
    reportIssueCallCount++;
    lastReportedBoxId = boxId;
    lastReportedReason = reason;
    lastReportedDescription = description;
    lastReportedPhotoKeys = photoStorageKeys;
    if (reportIssueDelay != null) {
      await Future<void>.delayed(reportIssueDelay!);
    }
    return reportIssueResult ?? const ApiSuccessResult(data: 'issue-uuid-1234');
  }

  @override
  Future<ApiResult<bool>> reportDelay({
    required String boxId,
    required int delayMinutes,
    String? reason,
  }) async {
    lastReportedBoxId = boxId;
    lastDelayMinutes = delayMinutes;
    lastDelayReason = reason;
    return reportDelayResult ?? const ApiSuccessResult(data: true);
  }

  @override
  Future<ApiResult<String>> uploadEvidence(File file) async {
    uploadEvidenceCallCount++;
    lastUploadedEvidenceFile = file;
    if (uploadEvidenceDelay != null) {
      await Future<void>.delayed(uploadEvidenceDelay!);
    }
    return uploadEvidenceResult ?? const ApiSuccessResult(data: 'storage-key-abc');
  }
}

void main() {
  group('DriverIssueViewModel', () {
    late MockDriverIssueRepository mockRepo;
    late DriverIssueViewModel viewModel;
    late Directory tempDir;

    File createPhoto(String name) {
      final file = File('${tempDir.path}/$name');
      file.writeAsBytesSync([1, 2, 3]);
      return file;
    }

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('issue_photo_test_');
      mockRepo = MockDriverIssueRepository();
      viewModel = DriverIssueViewModel(
        reportDriverIssueUseCase: ReportDriverIssueUseCase(mockRepo),
        reportDriverDelayUseCase: ReportDriverDelayUseCase(mockRepo),
        uploadDriverIssueEvidenceUseCase:
            UploadDriverIssueEvidenceUseCase(mockRepo),
      );
    });

    tearDown(() async {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
      await viewModel.close();
    });

    test('initial state has empty/default values', () {
      expect(viewModel.state.isSubmitting, isFalse);
      expect(viewModel.state.isSuccess, isFalse);
      expect(viewModel.state.failure, isNull);
      expect(viewModel.state.selectedReason, DeliveryIssueReason.customerNoAnswer);
      expect(viewModel.state.notes, isEmpty);
      expect(viewModel.state.photos, isEmpty);
    });

    test('SelectDeliveryIssueReasonEvent updates selectedReason', () async {
      viewModel.add(const SelectDeliveryIssueReasonEvent(DeliveryIssueReason.boxDamaged));
      await expectLater(
        viewModel.stream,
        emits(predicate<DriverIssueState>(
          (s) => s.selectedReason == DeliveryIssueReason.boxDamaged,
        )),
      );
    });

    test('AddDeliveryIssuePhotoEvent enforces max 3 photos', () async {
      viewModel.add(const AddDeliveryIssuePhotoEvent('photo1.jpg'));
      viewModel.add(const AddDeliveryIssuePhotoEvent('photo2.jpg'));
      viewModel.add(const AddDeliveryIssuePhotoEvent('photo3.jpg'));
      viewModel.add(const AddDeliveryIssuePhotoEvent('photo4.jpg')); // 4th should be ignored

      await expectLater(
        viewModel.stream,
        emitsThrough(predicate<DriverIssueState>(
          (s) => s.photos.length == 3 && !s.photos.contains('photo4.jpg'),
        )),
      );
    });

    test('SubmitDriverIssueEvent success with no photos', () async {
      mockRepo.reportIssueResult = const ApiSuccessResult(data: 'issue-uuid-999');

      final states = <DriverIssueState>[];
      final subscription = viewModel.stream.listen(states.add);

      viewModel.add(const UpdateDeliveryIssueNotesEvent('Delivery issue note'));
      viewModel.add(const SelectDeliveryIssueReasonEvent(DeliveryIssueReason.addressUnclear));
      viewModel.add(const SubmitDriverIssueEvent(boxId: 'box-uuid-1'));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(mockRepo.lastReportedBoxId, 'box-uuid-1');
      expect(mockRepo.lastReportedReason, DeliveryIssueReason.addressUnclear);
      expect(mockRepo.lastReportedDescription, 'Delivery issue note');
      expect(mockRepo.lastReportedPhotoKeys, isEmpty);

      expect(states.any((s) => s.isSubmitting), isTrue);
      final last = states.last;
      expect(last.isSubmitting, isFalse);
      expect(last.isSuccess, isTrue);
      expect(last.submittedIssueId, 'issue-uuid-999');
      expect(last.failure, isNull);
    });

    test('SubmitDriverIssueEvent failure emits error', () async {
      mockRepo.reportIssueResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Invalid assignment', code: 'INVALID_ASSIGNMENT'),
      );

      final states = <DriverIssueState>[];
      final subscription = viewModel.stream.listen(states.add);

      viewModel.add(const SubmitDriverIssueEvent(boxId: 'box-uuid-1'));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      final last = states.last;
      expect(last.isSubmitting, isFalse);
      expect(last.isSuccess, isFalse);
      expect(last.failure, isNotNull);
      expect(last.failure!.errorMessage, 'Invalid assignment');
      expect(last.failure!.code, 'INVALID_ASSIGNMENT');
    });

    test('ReportDriverDelayEvent success emits isSuccess', () async {
      mockRepo.reportDelayResult = const ApiSuccessResult(data: true);

      final states = <DriverIssueState>[];
      final subscription = viewModel.stream.listen(states.add);

      viewModel.add(const ReportDriverDelayEvent(
        boxId: 'box-uuid-delay',
        delayMinutes: 30,
        reason: 'Heavy traffic',
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(mockRepo.lastReportedBoxId, 'box-uuid-delay');
      expect(mockRepo.lastDelayMinutes, 30);
      expect(mockRepo.lastDelayReason, 'Heavy traffic');

      final last = states.last;
      expect(last.isSubmitting, isFalse);
      expect(last.isSuccess, isTrue);
    });

    test('ReportDriverDelayEvent failure emits error', () async {
      mockRepo.reportDelayResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Delay limit exceeded', code: 'DELAY_LIMIT'),
      );

      final states = <DriverIssueState>[];
      final subscription = viewModel.stream.listen(states.add);

      viewModel.add(const ReportDriverDelayEvent(
        boxId: 'box-uuid-delay',
        delayMinutes: 2000,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      final last = states.last;
      expect(last.isSubmitting, isFalse);
      expect(last.isSuccess, isFalse);
      expect(last.failure?.code, 'DELAY_LIMIT');
    });

    test('AddIssuePhotoItemEvent triggers immediate upload and updates status to success with storageKey', () async {
      final photo = createPhoto('photo_1.jpg');
      mockRepo.uploadEvidenceResult = const ApiSuccessResult(data: 'storage_key_backend_001');

      final states = <DriverIssueState>[];
      final subscription = viewModel.stream.listen(states.add);

      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p1', localPath: photo.path),
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(mockRepo.uploadEvidenceCallCount, equals(1));
      expect(mockRepo.lastUploadedEvidenceFile?.path, equals(photo.path));

      final last = states.last;
      expect(last.photoItems.length, equals(1));
      expect(last.photoItems.first.status, equals(IssuePhotoStatus.success));
      expect(last.photoItems.first.storageKey, equals('storage_key_backend_001'));
      expect(last.hasUploadingPhotos, isFalse);
      expect(last.hasFailedPhotos, isFalse);
      expect(last.validStorageKeys, equals(['storage_key_backend_001']));
    });

    test('Submitting issue with 3 uploaded photos sends only valid storage keys', () async {
      final photo1 = createPhoto('photo1.png');
      final photo2 = createPhoto('photo2.png');
      final photo3 = createPhoto('photo3.png');
      final photo4 = createPhoto('photo4.png');

      mockRepo.uploadEvidenceResult = const ApiSuccessResult(data: 'key_proof_1');
      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p1', localPath: photo1.path),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      mockRepo.uploadEvidenceResult = const ApiSuccessResult(data: 'key_proof_2');
      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p2', localPath: photo2.path),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      mockRepo.uploadEvidenceResult = const ApiSuccessResult(data: 'key_proof_3');
      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p3', localPath: photo3.path),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(viewModel.state.photoItems.length, equals(3));
      expect(viewModel.state.validStorageKeys, equals(['key_proof_1', 'key_proof_2', 'key_proof_3']));

      // Adding 4th photo should be ignored (capped at 3)
      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p4', localPath: photo4.path),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(viewModel.state.photoItems.length, equals(3));

      // Submit issue
      mockRepo.reportIssueResult = const ApiSuccessResult(data: 'issue-success-uuid');
      viewModel.add(const SubmitDriverIssueEvent(boxId: 'box-789'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(mockRepo.lastReportedBoxId, equals('box-789'));
      expect(mockRepo.lastReportedPhotoKeys, equals(['key_proof_1', 'key_proof_2', 'key_proof_3']));
      expect(viewModel.state.isSuccess, isTrue);
    });

    test('SubmitDriverIssueEvent is blocked while photos are uploading', () async {
      final slowPhoto = createPhoto('slow_photo.jpg');
      mockRepo.uploadEvidenceDelay = const Duration(milliseconds: 80);

      final states = <DriverIssueState>[];
      final subscription = viewModel.stream.listen(states.add);

      // Start upload
      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p_slow', localPath: slowPhoto.path),
      ));
      // Check intermediate state where upload is in progress
      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(viewModel.state.hasUploadingPhotos, isTrue);

      // Attempt to submit while uploading
      viewModel.add(const SubmitDriverIssueEvent(boxId: 'box-blocked'));
      await Future<void>.delayed(const Duration(milliseconds: 15));

      // Submission must not have been triggered
      expect(mockRepo.reportIssueCallCount, equals(0));

      // Wait for upload to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();
      expect(viewModel.state.hasUploadingPhotos, isFalse);
    });

    test('Photo upload failure marks item as failed and allows retry', () async {
      final failPhoto = createPhoto('fail_photo.jpg');
      mockRepo.uploadEvidenceResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Network error uploading', code: 'NETWORK_ERR'),
      );

      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p_fail', localPath: failPhoto.path),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.photoItems.length, equals(1));
      final failedPhoto = viewModel.state.photoItems.first;
      expect(failedPhoto.status, equals(IssuePhotoStatus.failed));
      expect(failedPhoto.storageKey, isNull);
      expect(viewModel.state.hasFailedPhotos, isTrue);
      expect(viewModel.state.validStorageKeys, isEmpty);

      // Retry upload with success
      mockRepo.uploadEvidenceResult = const ApiSuccessResult(data: 'retried_storage_key');
      viewModel.add(RetryIssuePhotoUploadEvent(failedPhoto.id));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.photoItems.first.status, equals(IssuePhotoStatus.success));
      expect(viewModel.state.photoItems.first.storageKey, equals('retried_storage_key'));
      expect(viewModel.state.hasFailedPhotos, isFalse);
    });

    test('RemoveIssuePhotoItemEvent removes photo from list', () async {
      final removePhoto = createPhoto('to_remove.jpg');
      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p_remove', localPath: removePhoto.path),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.photoItems.length, equals(1));
      final photoId = viewModel.state.photoItems.first.id;

      viewModel.add(RemoveIssuePhotoItemEvent(photoId));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(viewModel.state.photoItems, isEmpty);
      expect(viewModel.state.validStorageKeys, isEmpty);
    });

    test('SubmitDriverIssueEvent on driver.issue.photo_not_found resets photos to failed for re-upload and preserves notes', () async {
      final expiredPhoto = createPhoto('expired_photo.jpg');
      mockRepo.uploadEvidenceResult = const ApiSuccessResult(data: 'expired_key_123');
      viewModel.add(const UpdateDeliveryIssueNotesEvent('Preserved driver explanation'));
      viewModel.add(AddIssuePhotoItemEvent(
        IssuePhotoItem(id: 'p_expired', localPath: expiredPhoto.path),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.validStorageKeys, equals(['expired_key_123']));

      // Backend returns photo_not_found
      mockRepo.reportIssueResult = ApiErrorResult(
        failure: Failure(
          errorMessage: 'مفتاح صورة البلاغ لا يشير إلى ملفًا مرفوعًا فعليًا',
          code: 'driver.issue.photo_not_found',
        ),
      );

      viewModel.add(const SubmitDriverIssueEvent(boxId: 'box-photo-not-found'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Notes are preserved
      expect(viewModel.state.notes, equals('Preserved driver explanation'));
      expect(viewModel.state.failure?.code, equals('driver.issue.photo_not_found'));

      // Photo item status is marked failed with storageKey cleared
      expect(viewModel.state.photoItems.length, equals(1));
      final item = viewModel.state.photoItems.first;
      expect(item.status, equals(IssuePhotoStatus.failed));
      expect(item.storageKey, isNull);
      expect(viewModel.state.hasFailedPhotos, isTrue);

      // Driver can re-upload using ReuploadInvalidPhotosEvent
      mockRepo.uploadEvidenceResult = const ApiSuccessResult(data: 'fresh_valid_key_456');
      viewModel.add(const ReuploadInvalidPhotosEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(viewModel.state.photoItems.first.status, equals(IssuePhotoStatus.success));
      expect(viewModel.state.photoItems.first.storageKey, equals('fresh_valid_key_456'));
      expect(viewModel.state.validStorageKeys, equals(['fresh_valid_key_456']));
    });

    test('Prevents duplicate submission while isSubmitting is true', () async {
      mockRepo.reportIssueDelay = const Duration(milliseconds: 60);
      mockRepo.reportIssueResult = const ApiSuccessResult(data: 'issue-once-uuid');

      viewModel.add(const SubmitDriverIssueEvent(boxId: 'box-single'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      viewModel.add(const SubmitDriverIssueEvent(boxId: 'box-single')); // duplicate event
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(mockRepo.reportIssueCallCount, equals(1));
    });
  });
}

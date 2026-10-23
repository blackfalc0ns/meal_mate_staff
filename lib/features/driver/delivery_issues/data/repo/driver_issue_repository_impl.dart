import '../../../../../core/errors/api_exception.dart';
import '../../../../../core/errors/api_error_type.dart';

import 'dart:io';

import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../domain/entities/delivery_issue_reason.dart';
import '../../domain/repo/driver_issue_repository.dart';
import '../data_source/driver_issue_remote_data_source.dart';
import '../mapper/driver_issue_mapper.dart';

class DriverIssueRepositoryImpl implements DriverIssueRepository {
  const DriverIssueRepositoryImpl(this._remoteDataSource);

  final DriverIssueRemoteDataSource _remoteDataSource;

  static bool _isStorageKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('assets/')) return false;
    if (lower.startsWith('file://')) return false;
    if (lower.startsWith('/data/') ||
        lower.startsWith('/storage/') ||
        lower.startsWith('/var/') ||
        lower.startsWith('/private/') ||
        RegExp(r'^[a-zA-Z]:[/\\]').hasMatch(trimmed)) {
      return false;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    if (uri.hasScheme) {
      return uri.scheme == 'http' || uri.scheme == 'https';
    }
    return true;
  }

  static const int maxFileSizeBytes = 25 * 1024 * 1024;
  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  @override
  Future<ApiResult<String>> reportIssue({
    required String boxId,
    required DeliveryIssueReason reason,
    String? description,
    String? severity,
    List<String> photoStorageKeys = const [],
  }) {
    final keys = photoStorageKeys
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    if (keys.any((key) => !_isStorageKey(key)) || keys.toSet().length > 3) {
      return Future.value(
        ApiErrorResult<String>(
          failure: Failure.fromException(
            const ApiException(
              errorType: ApiErrorType.validationError,
              message:
                  'مفتاح الصورة غير صالح. أعد رفع الصورة قبل إرسال البلاغ.',
              backendErrorCode: 'ISSUE_UPLOAD_STORAGE_KEY_INVALID',
            ),
          ),
        ),
      );
    }
    final dto = DriverIssueMapper.toReportDto(
      reason: reason,
      description: description,
      severity: severity,
      photoStorageKeys: keys,
    );
    return safeApiCall(() => _remoteDataSource.reportIssue(boxId, dto));
  }

  @override
  Future<ApiResult<bool>> reportDelay({
    required String boxId,
    required int delayMinutes,
    String? reason,
  }) {
    final dto = DriverIssueMapper.toDelayDto(
      delayMinutes: delayMinutes,
      reason: reason,
    );
    return safeApiCall(() => _remoteDataSource.reportDelay(boxId, dto));
  }

  @override
  Future<ApiResult<String>> uploadEvidence(File file) async {
    final path = file.path.toLowerCase();
    final dotIndex = path.lastIndexOf('.');
    final ext = dotIndex != -1 ? path.substring(dotIndex + 1) : '';

    if (!allowedExtensions.contains(ext)) {
      return ApiErrorResult<String>(
        failure: Failure(
          errorMessage: 'Unsupported image format. Allowed: JPG, PNG, WebP',
          code: 'UNSUPPORTED_MEDIA_TYPE',
        ),
      );
    }

    try {
      final length = await file.length();
      if (length > maxFileSizeBytes) {
        return ApiErrorResult<String>(
          failure: Failure(
            errorMessage: 'Image size exceeds maximum limit of 25 MB',
            code: 'FILE_TOO_LARGE',
          ),
        );
      }
    } catch (_) {
      // If file length cannot be read, proceed to let network/system handle it
    }

    return safeApiCall(() async {
      final response = await _remoteDataSource.uploadEvidence(file);
      final key = response.storageKey?.trim();
      if (key == null || !_isStorageKey(key)) {
        throw const ApiException(
          errorType: ApiErrorType.validationError,
          message:
              'رد رفع الصورة لا يحتوي storageKey صالحًا. يلزم مراجعة رد /api/v1/uploads مع الباك.',
          backendErrorCode: 'ISSUE_UPLOAD_STORAGE_KEY_INVALID',
        );
      }
      return key;
    });
  }
}

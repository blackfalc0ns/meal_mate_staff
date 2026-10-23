import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_support_add_photos_result_entity.dart';
import '../../domain/entities/driver_support_issues_page_entity.dart';
import '../../domain/entities/driver_support_issues_query_entity.dart';
import '../../domain/entities/driver_support_ticket_details_entity.dart';
import '../../domain/repo/driver_support_repository.dart';
import '../data_source/driver_support_remote_data_source.dart';
import '../mapper/driver_support_mapper.dart';
import '../models/request/driver_support_add_photos_request_dto.dart';

@Injectable(as: DriverSupportRepository)
class DriverSupportRepositoryImpl implements DriverSupportRepository {
  const DriverSupportRepositoryImpl(this._remoteDataSource);

  final DriverSupportRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverSupportIssuesPageEntity>> getSupportIssues(
    DriverSupportIssuesQueryEntity query,
  ) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getIssues(
        status: query.backendStatus,
        search: query.search?.trim().isEmpty ?? true ? null : query.search!.trim(),
        pageNumber: query.pageNumber,
        pageSize: query.pageSize,
      );
      return DriverSupportMapper.mapIssuesPageToEntity(response);
    });
  }

  @override
  Future<ApiResult<DriverSupportTicketDetailsEntity>> getSupportIssueDetails(
    String issueId,
  ) {
    final cleanId = issueId.trim();
    if (cleanId.isEmpty) {
      return Future.value(
        ApiErrorResult<DriverSupportTicketDetailsEntity>(
          failure: Failure(
            errorMessage: 'معرف البلاغ غير صالح',
            code: 'DRIVER_SUPPORT_ISSUE_INVALID_ID',
          ),
        ),
      );
    }

    return safeApiCall(() async {
      final response = await _remoteDataSource.getIssueDetails(cleanId);
      return DriverSupportMapper.mapDetailsToEntity(response);
    });
  }

  @override
  Future<ApiResult<DriverSupportAddPhotosResultEntity>> addSupportIssuePhotos(
    String issueId,
    List<String> storageKeys,
  ) {
    final cleanId = issueId.trim();
    if (cleanId.isEmpty) {
      return Future.value(
        ApiErrorResult<DriverSupportAddPhotosResultEntity>(
          failure: Failure(
            errorMessage: 'معرف البلاغ غير صالح',
            code: 'DRIVER_SUPPORT_ISSUE_INVALID_ID',
          ),
        ),
      );
    }

    // Deduplicate and filter out invalid local device paths
    final cleanKeys = storageKeys
        .map((k) => k.trim())
        .where((k) {
          if (k.isEmpty) return false;
          final lower = k.toLowerCase();
          if (lower.startsWith('assets/')) return false;
          if (lower.startsWith('file://')) return false;
          if (lower.startsWith('/data/') ||
              lower.startsWith('/storage/') ||
              lower.startsWith('/var/') ||
              lower.startsWith('/private/') ||
              RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(k)) {
            return false;
          }
          final uri = Uri.tryParse(k);
          if (uri == null) return false;
          if (uri.hasScheme) {
            return uri.scheme == 'http' || uri.scheme == 'https';
          }
          return true;
        })
        .toSet()
        .toList();

    if (cleanKeys.isEmpty) {
      return Future.value(
        ApiErrorResult<DriverSupportAddPhotosResultEntity>(
          failure: Failure(
            errorMessage: 'قائمة مفاتيح الصور فارغة أو غير صالحة',
            code: 'DRIVER_SUPPORT_PHOTOS_INVALID',
          ),
        ),
      );
    }

    return safeApiCall(() async {
      final request = DriverSupportAddPhotosRequestDto(
        storageKeys: cleanKeys,
      );
      final response = await _remoteDataSource.addPhotos(cleanId, request);
      return DriverSupportMapper.mapAddPhotosResultToEntity(response);
    });
  }
}

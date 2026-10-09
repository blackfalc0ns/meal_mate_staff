import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/reassignment_request_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';
import '../../domain/repo/driver_reassignment_repository.dart';
import '../data_source/driver_reassignment_remote_data_source.dart';
import '../mapper/driver_reassignment_mapper.dart';

@Injectable(as: DriverReassignmentRepository)
class DriverReassignmentRepositoryImpl implements DriverReassignmentRepository {
  const DriverReassignmentRepositoryImpl(this._remoteDataSource);

  final DriverReassignmentRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<ReassignmentResultEntity>> submit({
    required String boxId,
    required ReassignmentRequestEntity request,
  }) {
    return safeApiCall(() async {
      final cleanBoxId = boxId.trim();
      if (cleanBoxId.isEmpty) {
        throw const FormatException('Target boxId cannot be empty.');
      }

      if (request.notes.trim().length > 250) {
        throw const FormatException('Notes exceed maximum length of 250 characters.');
      }

      final dto = await _remoteDataSource.submit(
        boxId: cleanBoxId,
        request: request.toDto(),
      );

      return dto.toEntity(targetBoxId: cleanBoxId);
    });
  }
}

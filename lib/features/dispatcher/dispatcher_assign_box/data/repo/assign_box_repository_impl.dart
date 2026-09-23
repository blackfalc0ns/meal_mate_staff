import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/assign_box_details_entity.dart';
import '../../domain/entities/assign_box_summary_entity.dart';
import '../../domain/repo/assign_box_repository.dart';
import '../data_source/assign_box_remote_data_source.dart';
import '../mapper/assign_box_mapper.dart';

@LazySingleton(as: AssignBoxRepository)
class AssignBoxRepositoryImpl implements AssignBoxRepository {
  const AssignBoxRepositoryImpl(this._remoteDataSource);

  final AssignBoxRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<AssignBoxDetailsEntity>> getDetails(String boxId) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getDetails(boxId);
      return response.toEntity();
    });
  }

  @override
  Future<ApiResult<AssignBoxSummaryEntity>> getSummary(String boxId) {
    return safeApiCall(() async {
      final response = await _remoteDataSource.getSummary(boxId);
      return response.toEntity();
    });
  }
}

import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../../domain/entities/dispatcher_support_response_entity.dart';
import '../../domain/repo/dispatcher_support_repository.dart';
import '../data_source/dispatcher_support_remote_data_source.dart';
import '../mapper/dispatcher_support_mapper.dart';

class DispatcherSupportRepositoryImpl implements DispatcherSupportRepository {
  const DispatcherSupportRepositoryImpl(this._remoteDataSource);

  final DispatcherSupportRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DispatcherSupportResponseEntity>> getIssues(
    DispatcherSupportQueryEntity query,
  ) {
    return safeApiCall(() async {
      final responseDto = await _remoteDataSource.getIssues(query);
      return responseDto.toEntity();
    });
  }
}

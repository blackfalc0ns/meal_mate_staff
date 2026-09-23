import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../domain/entities/operations_page_entity.dart';
import '../../domain/entities/operations_query_entity.dart';
import '../../domain/repo/operations_log_repository.dart';
import '../data_source/operations_log_remote_data_source.dart';
import '../mapper/operations_log_mapper.dart';

@LazySingleton(as: OperationsLogRepository)
class OperationsLogRepositoryImpl implements OperationsLogRepository {
  const OperationsLogRepositoryImpl(this._remoteDataSource);

  final OperationsLogRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<OperationsPageEntity>> getOperations(
    OperationsQueryEntity query,
  ) {
    return safeApiCall(() async {
      final responseDto = await _remoteDataSource.getOperations(query);
      return responseDto.toEntity();
    });
  }
}

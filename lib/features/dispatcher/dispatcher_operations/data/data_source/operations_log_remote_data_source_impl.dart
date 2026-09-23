import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import '../../domain/entities/operation_status.dart';
import '../../domain/entities/operations_query_entity.dart';
import '../models/response/operations_log_response_dto.dart';
import 'operations_log_remote_data_source.dart';

@LazySingleton(as: OperationsLogRemoteDataSource)
class OperationsLogRemoteDataSourceImpl
    implements OperationsLogRemoteDataSource {
  const OperationsLogRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<OperationsLogResponseDto> getOperations(OperationsQueryEntity query) {
    final trimmedSearch = query.search.trim();

    return _apiServices.getDispatcherOperationsLog(
      restaurantId: query.restaurantId,
      status: query.status == OperationStatus.all
          ? null
          : query.status.apiValue,
      search: trimmedSearch.isEmpty ? null : trimmedSearch,
      datePreset: query.datePreset.apiValue,
      fromDateUtc: query.fromDateUtc?.toUtc().toIso8601String(),
      toDateUtc: query.toDateUtc?.toUtc().toIso8601String(),
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
    );
  }
}

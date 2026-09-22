import 'package:meal_mate_delivery/core/network/api_services.dart';
import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../models/response/dispatcher_support_response_dto.dart';
import 'dispatcher_support_remote_data_source.dart';

class DispatcherSupportRemoteDataSourceImpl
    implements DispatcherSupportRemoteDataSource {
  const DispatcherSupportRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DispatcherSupportResponseDto> getIssues(
    DispatcherSupportQueryEntity query,
  ) {
    return _apiServices.getDispatcherSupportIssues(
      area: query.area,
      status: query.apiStatus,
      search: query.search.trim().isEmpty ? null : query.search.trim(),
      datePreset: query.apiDatePreset,
      fromDateUtc: query.fromDateUtc?.toUtc().toIso8601String(),
      toDateUtc: query.toDateUtc?.toUtc().toIso8601String(),
      pageNumber: query.pageNumber,
      pageSize: query.pageSize,
    );
  }
}

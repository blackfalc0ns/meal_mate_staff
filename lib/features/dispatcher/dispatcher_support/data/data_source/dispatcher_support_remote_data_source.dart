import '../../domain/entities/dispatcher_support_query_entity.dart';
import '../models/response/dispatcher_support_response_dto.dart';

abstract class DispatcherSupportRemoteDataSource {
  Future<DispatcherSupportResponseDto> getIssues(
    DispatcherSupportQueryEntity query,
  );
}

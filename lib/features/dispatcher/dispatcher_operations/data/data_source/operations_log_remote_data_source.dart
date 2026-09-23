import '../../domain/entities/operations_query_entity.dart';
import '../models/response/operations_log_response_dto.dart';

abstract interface class OperationsLogRemoteDataSource {
  Future<OperationsLogResponseDto> getOperations(OperationsQueryEntity query);
}

import '../../../../../core/network/api_results.dart';
import '../entities/assign_box_details_entity.dart';
import '../entities/assign_box_summary_entity.dart';

abstract interface class AssignBoxRepository {
  Future<ApiResult<AssignBoxDetailsEntity>> getDetails(String boxId);
  Future<ApiResult<AssignBoxSummaryEntity>> getSummary(String boxId);
}

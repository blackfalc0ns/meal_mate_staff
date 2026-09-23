import '../models/response/assign_box_details_response_dto.dart';
import '../models/response/assign_box_summary_response_dto.dart';

abstract interface class AssignBoxRemoteDataSource {
  Future<AssignBoxDetailsResponseDto> getDetails(String boxId);
  Future<AssignBoxSummaryResponseDto> getSummary(String boxId);
}

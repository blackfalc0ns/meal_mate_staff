import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/assign_box_details_response_dto.dart';
import '../models/response/assign_box_summary_response_dto.dart';
import 'assign_box_remote_data_source.dart';

@LazySingleton(as: AssignBoxRemoteDataSource)
class AssignBoxRemoteDataSourceImpl implements AssignBoxRemoteDataSource {
  const AssignBoxRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<AssignBoxDetailsResponseDto> getDetails(String boxId) {
    return _apiServices.getAssignBoxDetails(boxId);
  }

  @override
  Future<AssignBoxSummaryResponseDto> getSummary(String boxId) {
    return _apiServices.getAssignBoxSummary(boxId);
  }
}

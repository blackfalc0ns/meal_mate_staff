import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_support_ticket_details_entity.dart';
import '../repo/driver_support_repository.dart';

@injectable
class GetDriverSupportIssueDetailsUseCase {
  const GetDriverSupportIssueDetailsUseCase(this._repository);

  final DriverSupportRepository _repository;

  Future<ApiResult<DriverSupportTicketDetailsEntity>> call(String issueId) {
    return _repository.getSupportIssueDetails(issueId);
  }
}

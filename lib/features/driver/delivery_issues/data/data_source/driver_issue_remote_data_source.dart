import 'dart:io';

import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_delivery_proof_upload_response_dto.dart';
import '../models/request/driver_report_delay_request_dto.dart';
import '../models/request/driver_report_issue_request_dto.dart';

abstract class DriverIssueRemoteDataSource {
  Future<String> reportIssue(
    String boxId,
    DriverReportIssueRequestDto request,
  );

  Future<bool> reportDelay(
    String boxId,
    DriverReportDelayRequestDto request,
  );

  Future<DriverDeliveryProofUploadResponseDto> uploadEvidence(File file);
}

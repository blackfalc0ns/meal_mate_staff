import 'dart:io';

import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/data/models/response/driver_delivery_proof_upload_response_dto.dart';
import '../models/request/driver_report_delay_request_dto.dart';
import '../models/request/driver_report_issue_request_dto.dart';
import 'driver_issue_remote_data_source.dart';

class DriverIssueRemoteDataSourceImpl implements DriverIssueRemoteDataSource {
  const DriverIssueRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<String> reportIssue(
    String boxId,
    DriverReportIssueRequestDto request,
  ) {
    return _apiServices.reportDriverIssue(boxId, request);
  }

  @override
  Future<bool> reportDelay(
    String boxId,
    DriverReportDelayRequestDto request,
  ) {
    return _apiServices.reportDriverDelay(boxId, request);
  }

  @override
  Future<DriverDeliveryProofUploadResponseDto> uploadEvidence(File file) {
    return _apiServices.uploadDriverIssueEvidence(file);
  }
}

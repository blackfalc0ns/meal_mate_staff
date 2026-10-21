import 'dart:io';

import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/delivery_issue_reason.dart';

abstract class DriverIssueRepository {
  Future<ApiResult<String>> reportIssue({
    required String boxId,
    required DeliveryIssueReason reason,
    String? description,
    String? severity,
    List<String> photoStorageKeys = const [],
  });

  Future<ApiResult<bool>> reportDelay({
    required String boxId,
    required int delayMinutes,
    String? reason,
  });

  Future<ApiResult<String>> uploadEvidence(File file);
}

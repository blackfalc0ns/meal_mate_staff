import '../../../../../core/network/api_results.dart';
import '../entities/driver_arrival_request_entity.dart';
import '../entities/driver_arrival_result_entity.dart';
import '../entities/driver_deliver_request_entity.dart';
import '../entities/driver_deliver_result_entity.dart';
import '../entities/driver_delivery_proof_upload_entity.dart';

abstract interface class DriverDeliveryRepository {
  Future<ApiResult<DriverArrivalResultEntity>> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestEntity request,
  });

  Future<ApiResult<DriverDeliveryProofUploadEntity>> uploadProof({
    required String localPath,
  });

  Future<ApiResult<DriverDeliverResultEntity>> deliverOrder({
    required String boxId,
    required DriverDeliverRequestEntity request,
  });
}

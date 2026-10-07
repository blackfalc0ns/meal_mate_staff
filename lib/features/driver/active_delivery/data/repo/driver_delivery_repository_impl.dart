import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_arrival_request_entity.dart';
import '../../domain/entities/driver_arrival_result_entity.dart';
import '../../domain/entities/driver_deliver_request_entity.dart';
import '../../domain/entities/driver_deliver_result_entity.dart';
import '../../domain/entities/driver_delivery_proof_upload_entity.dart';
import '../../domain/repo/driver_delivery_repository.dart';
import '../data_source/driver_delivery_remote_data_source.dart';
import '../mapper/driver_delivery_mapper.dart';

@Injectable(as: DriverDeliveryRepository)
class DriverDeliveryRepositoryImpl implements DriverDeliveryRepository {
  const DriverDeliveryRepositoryImpl(this._remoteDataSource);

  final DriverDeliveryRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverArrivalResultEntity>> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestEntity request,
  }) {
    return safeApiCall(() async {
      final dto = await _remoteDataSource.arriveAtCustomer(
        boxId: boxId,
        request: request.toDto(),
      );
      return dto.toEntity(fallbackBoxId: boxId);
    });
  }

  @override
  Future<ApiResult<DriverDeliveryProofUploadEntity>> uploadProof({
    required String localPath,
  }) {
    return safeApiCall(() async {
      final file = File(localPath);
      final dto = await _remoteDataSource.uploadProof(file: file);
      final entity = dto.toEntity();
      if (entity.storageKey.isEmpty) {
        throw Exception('Server returned empty proof photo storage key.');
      }
      return entity;
    });
  }

  @override
  Future<ApiResult<DriverDeliverResultEntity>> deliverOrder({
    required String boxId,
    required DriverDeliverRequestEntity request,
  }) {
    return safeApiCall(() async {
      final dto = await _remoteDataSource.deliverOrder(
        boxId: boxId,
        request: request.toDto(),
      );
      return dto.toEntity(fallbackBoxId: boxId);
    });
  }
}

import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../domain/entities/driver_file_upload_result_entity.dart';
import '../../domain/entities/driver_registration_draft_entity.dart';
import '../../domain/entities/driver_registration_result_entity.dart';
import '../../domain/entities/driver_restaurant_entity.dart';
import '../../domain/entities/driver_resubmit_entity.dart';
import '../../domain/repo/driver_registration_repository.dart';
import '../data_source/driver_registration_remote_data_source.dart';
import '../mapper/driver_registration_mapper.dart';

@LazySingleton(as: DriverRegistrationRepository)
class DriverRegistrationRepositoryImpl implements DriverRegistrationRepository {
  const DriverRegistrationRepositoryImpl(this._remoteDataSource);

  final DriverRegistrationRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() {
    return safeApiCall<List<DriverRestaurantEntity>>(() async {
      final dtoList = await _remoteDataSource.getRestaurants();
      return dtoList.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(File file) {
    return safeApiCall<DriverFileUploadResultEntity>(() async {
      final dto = await _remoteDataSource.uploadDocument(file);
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) {
    return safeApiCall<DriverRegistrationResultEntity>(() async {
      final dto = await _remoteDataSource.submitRegistration(draft.toDto());
      return dto.toEntity();
    });
  }

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) {
    return safeApiCall<DriverRegistrationResultEntity>(() async {
      final dto = await _remoteDataSource.resubmitRegistration(
        registrationId,
        resubmitData.toDto(),
      );
      return dto.toEntity();
    });
  }
}

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repo/driver_profile_repository.dart';
import '../data_source/driver_profile_remote_data_source.dart';
import '../mapper/driver_profile_mapper.dart';

@LazySingleton(as: DriverProfileRepository)
class DriverProfileRepositoryImpl implements DriverProfileRepository {
  const DriverProfileRepositoryImpl(this._remote);

  final DriverProfileRemoteDataSource _remote;

  @override
  Future<ApiResult<DriverProfileEntity>> getProfile() =>
      safeApiCall(() async => (await _remote.getProfile()).toEntity());
}

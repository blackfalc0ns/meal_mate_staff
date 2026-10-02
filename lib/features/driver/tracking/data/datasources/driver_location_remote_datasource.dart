import 'package:dio/dio.dart';
import '../../../../../core/network/network_constants.dart';

abstract interface class DriverLocationRemoteDataSource {
  Future<Map<String, dynamic>?> sendLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  });
}

class DriverLocationRemoteDataSourceImpl
    implements DriverLocationRemoteDataSource {
  DriverLocationRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>?> sendLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async {
    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      // ignore: use_null_aware_elements
      if (heading != null) 'heading': heading,
      // ignore: use_null_aware_elements
      if (speedKmh != null) 'speedKmh': speedKmh,
    };

    final response = await _dio.post(
      EndPoints.driverLocation,
      data: payload,
    );

    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return null;
  }
}

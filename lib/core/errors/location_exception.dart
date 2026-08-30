enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.type);

  final LocationErrorType type;
}

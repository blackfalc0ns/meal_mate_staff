abstract class NetworkConstants {
  static const String baseUrl = 'http://maelmate.runasp.net';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}

abstract class EndPoints {
  static const String refresh = '/api/v1/auth/refresh';

  // Shared staff auth endpoints
  static const String lookupPhone = '/api/v1/auth/staff/lookup-phone';
  static const String verifyFirstTimeOtp =
      '/api/v1/auth/staff/verify-first-time-otp';
  static const String setPassword = '/api/v1/auth/staff/set-password';
  static const String login = '/api/v1/auth/staff/login';
  static const String forgotPassword = '/api/v1/auth/staff/forgot-password';
  static const String resetPassword = '/api/v1/auth/staff/reset-password';
  static const String resendOtp = '/api/v1/auth/staff/resend-otp';
  static const String staffRoles = '/api/v1/auth/staff/roles';

  // Driver registration and status endpoints
  static const String driverRestaurants =
      '/api/v1/auth/staff/driver-registration/restaurants';
  static const String driverNationalities =
      '/api/v1/auth/staff/driver-registration/nationalities';
  static const String driverVehicleTypes =
      '/api/v1/auth/staff/driver-registration/vehicle-types';
  static const String driverVehicleColors =
      '/api/v1/auth/staff/driver-registration/vehicle-colors';
  static const String driverVehicleModels =
      '/api/v1/auth/staff/driver-registration/vehicle-models';
  static const String driverRegistrationUpload =
      '/api/v1/auth/staff/driver-registration/upload';
  static const String driverRegistration =
      '/api/v1/auth/staff/driver-registration';
  static const String driverRegistrationStatus =
      '/api/v1/auth/staff/driver-registration/status';
  static const String driverRegistrationResubmit =
      '/api/v1/auth/staff/driver-registration/{registrationId}/resubmit';

  static const String dispatcherDashboardOverview =
      '/api/v1/dispatcher/dashboard/overview';
  static const String dispatcherLiveLocations =
      '/api/v1/dispatcher/drivers/live-locations';
  static const String dispatcherOrdersQueue = '/api/v1/dispatcher/orders/queue';
  static const String dispatcherLiveMonitoring =
      '/api/v1/dispatcher/drivers/live-monitoring';
  static const String dispatcherHub = '/hubs/dispatcher';
  static const String dispatcherSupportIssues =
      '/api/v1/dispatcher/support/issues';
  static const String dispatcherPerformanceOverview =
      '/api/v1/dispatcher/performance/overview';
  static const String dispatcherPerformanceComparison =
      '/api/v1/dispatcher/performance/comparison';
  static const String dispatcherOperationsLog =
      '/api/v1/dispatcher/operations/log';
  static const String dispatcherDriversRoster =
      '/api/v1/dispatcher/drivers/roster';
  static const String dispatcherAssignOrder =
      '/api/v1/dispatcher/orders/{boxId}/assign';
  static const String dispatcherAssignmentDetails =
      '/api/v1/dispatcher/orders/{boxId}/assignment-details';
  static const String dispatcherOrderSummary =
      '/api/v1/dispatcher/orders/{boxId}/summary';
  static const String dispatcherOrderTracking =
      '/api/v1/dispatcher/orders/{boxId}/tracking';
  static const String dispatcherOrderIssues =
      '/api/v1/dispatcher/orders/{boxId}/issues';
  static const String dispatcherDriverDetails =
      '/api/v1/dispatcher/drivers/{driverId}/details';
  static const String dispatcherDriverActiveBoxes =
      '/api/v1/dispatcher/drivers/{driverId}/active-boxes';
  static const String dispatcherDriverCurrentLocation =
      '/api/v1/dispatcher/drivers/{driverId}/current-location';
}


abstract class NetworkConstants {
  static const String baseUrl = 'https://maelmate.runasp.net';
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

  // Driver auth endpoints
  static const String driverLookupPhone = '/api/v1/auth/drivers/lookup-phone';
  static const String driverFirstTimeSetup =
      '/api/v1/auth/drivers/first-time-setup';
  static const String driverLogin = '/api/v1/auth/drivers/login';
  static const String driverResendOtp = '/api/v1/auth/drivers/resend-otp';
  static const String driverVerifyOtp = '/api/v1/auth/drivers/verify-otp';
  static const String driverForgotPassword =
      '/api/v1/auth/drivers/forgot-password';
  static const String driverResetPassword =
      '/api/v1/auth/drivers/reset-password';
  static const String driverRegistrationDetails =
      '/api/v1/drivers/registrations/{id}';

  // Driver notifications endpoints
  static const String driverNotifications = '/api/v1/driver/notifications';
  static const String driverNotificationRead =
      '/api/v1/driver/notifications/{id}/read';
  static const String driverDeviceTokenDeactivate =
      '/api/v1/driver/device-token/deactivate';

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

  // Device token endpoints
  static const String driverDeviceToken = '/api/v1/driver/device-token';
  static const String restaurantDeviceTokens =
      '/api/v1/restaurants/device-tokens';

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
  static const String dispatcherDriversStatus = '/api/v1/dispatcher/drivers';
  static const String dispatcherDriverAvailability =
      '/api/v1/dispatcher/drivers/{driverId}/shift-status';
  static const String dispatcherDriverStatusDetails =
      '/api/v1/dispatcher/drivers/{driverId}';
  static const String dispatcherDriversStatusHub = '/hubs/dispatcher-hub';
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

  // Driver pickup flow endpoints
  static const String driverPickupManifest = '/api/v1/driver/pickup/manifest';
  static const String driverPickupValidateBarcode =
      '/api/v1/driver/pickup/validate-barcode';
  static const String driverPickupConditionPhoto =
      '/api/v1/driver/pickup/boxes/{boxId}/condition-photo';
  static const String driverPickupConfirm =
      '/api/v1/driver/pickup/boxes/{boxId}/confirm';
  static const String driverPickupSummary =
      '/api/v1/driver/trips/{tripId}/pickup-summary';
  static const String driverTripStart = '/api/v1/driver/trips/{tripId}/start';

  // Driver orders (Screen 05.05) & realtime endpoints
  static const String driverOrders = '/api/v1/driver/orders';
  static const String driverCallProxy =
      '/api/v1/driver/orders/{boxId}/call-proxy';
  static const String driverHub = '/hubs/driver-hub';
  static const String driverHubAlternative = '/hubs/driver';
  static const String driverLocation = '/api/v1/driver/location';

  // Driver profile (Screen 09.02)
  static const String driverProfile = '/api/v1/driver/profile';

  // Driver home (Screen 05.01 / 05.02)
  static const String driverHome = '/api/v1/driver/home';

  // Driver map (Screen 03.01)
  static const String driverMapRoute = '/api/v1/driver/map/route';
}

sealed class DriverMapEvent {
  const DriverMapEvent();
}

final class DriverMapActivated extends DriverMapEvent {
  const DriverMapActivated();
}

final class DriverMapDeactivated extends DriverMapEvent {
  const DriverMapDeactivated();
}

final class DriverMapAppResumed extends DriverMapEvent {
  const DriverMapAppResumed();
}

final class DriverMapAppPaused extends DriverMapEvent {
  const DriverMapAppPaused();
}

final class DriverMapRefreshRequested extends DriverMapEvent {
  const DriverMapRefreshRequested();
}

final class DriverMapRetryRequested extends DriverMapEvent {
  const DriverMapRetryRequested();
}

final class DriverMapStopSelected extends DriverMapEvent {
  const DriverMapStopSelected(this.stopId);
  final String stopId;
}

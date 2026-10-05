sealed class DriverHomeEvent {
  const DriverHomeEvent();

  const factory DriverHomeEvent.initialLoad() = DriverHomeLoadStarted;
  const factory DriverHomeEvent.refresh() = DriverHomeRefreshRequested;
  const factory DriverHomeEvent.retry() = DriverHomeRetryRequested;
  const factory DriverHomeEvent.lifecycleResume() = DriverHomeLifecycleResumed;
  const factory DriverHomeEvent.statusUpdated() =
      DriverHomeStatusUpdatedReceived;
  const factory DriverHomeEvent.signalRReconnected() =
      DriverHomeSignalRReconnected;
}

typedef DriverHomeInitialLoadEvent = DriverHomeLoadStarted;
typedef DriverHomeRefreshEvent = DriverHomeRefreshRequested;
typedef DriverHomeRetryEvent = DriverHomeRetryRequested;
typedef DriverHomeLifecycleResumeEvent = DriverHomeLifecycleResumed;
typedef DriverHomeStatusUpdatedEvent = DriverHomeStatusUpdatedReceived;
typedef DriverHomeSignalRReconnectedEvent = DriverHomeSignalRReconnected;

class DriverHomeLoadStarted extends DriverHomeEvent {
  const DriverHomeLoadStarted();
}

class DriverHomeRefreshRequested extends DriverHomeEvent {
  const DriverHomeRefreshRequested();
}

class DriverHomeRetryRequested extends DriverHomeEvent {
  const DriverHomeRetryRequested();
}

class DriverHomeLifecycleResumed extends DriverHomeEvent {
  const DriverHomeLifecycleResumed();
}

class DriverHomeStatusUpdatedReceived extends DriverHomeEvent {
  const DriverHomeStatusUpdatedReceived();
}

class DriverHomeSignalRReconnected extends DriverHomeEvent {
  const DriverHomeSignalRReconnected();
}

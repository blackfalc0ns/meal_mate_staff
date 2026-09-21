sealed class DispatcherHomeEvent {
  const DispatcherHomeEvent();
}

class DispatcherHomeLoadEvent extends DispatcherHomeEvent {
  const DispatcherHomeLoadEvent();
}

class DispatcherHomeRefreshEvent extends DispatcherHomeEvent {
  const DispatcherHomeRefreshEvent();
}

class DispatcherHomeRetryOverviewEvent extends DispatcherHomeEvent {
  const DispatcherHomeRetryOverviewEvent();
}

class DispatcherHomeRetryLiveDriversEvent extends DispatcherHomeEvent {
  const DispatcherHomeRetryLiveDriversEvent();
}

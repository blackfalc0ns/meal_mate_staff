sealed class DriverProfileEvent {
  const DriverProfileEvent();
}

class DriverProfileStarted extends DriverProfileEvent {
  const DriverProfileStarted({required this.locale});
  final String locale;
}

class DriverProfileRefreshed extends DriverProfileEvent {
  const DriverProfileRefreshed({required this.locale});
  final String locale;
}

class DriverProfileLocaleChanged extends DriverProfileEvent {
  const DriverProfileLocaleChanged({required this.locale});
  final String locale;
}

class DriverProfileActivated extends DriverProfileEvent {
  const DriverProfileActivated({required this.locale});
  final String locale;
}

class DriverProfileAvatarFailed extends DriverProfileEvent {
  const DriverProfileAvatarFailed({required this.locale});
  final String locale;
}

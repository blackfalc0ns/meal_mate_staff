sealed class DispatcherAuthDestination {
  const DispatcherAuthDestination();
}

class DispatcherFirstTimeOtpDestination extends DispatcherAuthDestination {
  const DispatcherFirstTimeOtpDestination({
    required this.phone,
    this.fullName,
    this.restaurantName,
  });

  final String phone;
  final String? fullName;
  final String? restaurantName;
}

class DispatcherPasswordLoginDestination extends DispatcherAuthDestination {
  const DispatcherPasswordLoginDestination({
    required this.phone,
    this.fullName,
    this.restaurantName,
  });

  final String phone;
  final String? fullName;
  final String? restaurantName;
}

class DispatcherAccountNotFoundDestination extends DispatcherAuthDestination {
  const DispatcherAccountNotFoundDestination({required this.phone});

  final String phone;
}

class DispatcherHomeDestination extends DispatcherAuthDestination {
  const DispatcherHomeDestination();
}

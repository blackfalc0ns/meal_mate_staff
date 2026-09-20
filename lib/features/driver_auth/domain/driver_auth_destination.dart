import '../../account_status/domain/account_status_kind.dart';

sealed class DriverAuthDestination {
  const DriverAuthDestination();
}

class DriverRegistrationDestination extends DriverAuthDestination {
  const DriverRegistrationDestination({this.phone});
  final String? phone;
}

class DriverFirstTimeOtpDestination extends DriverAuthDestination {
  const DriverFirstTimeOtpDestination({
    required this.phone,
    this.fullName,
    this.restaurantName,
  });
  final String phone;
  final String? fullName;
  final String? restaurantName;
}

class DriverPasswordLoginDestination extends DriverAuthDestination {
  const DriverPasswordLoginDestination({
    required this.phone,
    this.fullName,
    this.restaurantName,
  });
  final String phone;
  final String? fullName;
  final String? restaurantName;
}

class DriverAccountStatusDestination extends DriverAuthDestination {
  const DriverAccountStatusDestination({
    required this.kind,
    this.registrationId,
    this.title,
    this.subtitle,
    this.canResubmit = false,
  });
  final AccountStatusKind kind;
  final String? registrationId;
  final String? title;
  final String? subtitle;
  final bool canResubmit;
}

class DriverHomeDestination extends DriverAuthDestination {
  const DriverHomeDestination();
}

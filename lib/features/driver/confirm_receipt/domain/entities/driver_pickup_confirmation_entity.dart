enum DriverPickupNextAction {
  showBoxSuccess,
  showPickupSummary,
  unknown;

  static DriverPickupNextAction fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'showboxsuccess':
        return DriverPickupNextAction.showBoxSuccess;
      case 'showpickupsummary':
        return DriverPickupNextAction.showPickupSummary;
      default:
        return DriverPickupNextAction.unknown;
    }
  }
}

class DriverPickupConfirmationEntity {
  const DriverPickupConfirmationEntity({
    required this.boxId,
    required this.boxCode,
    required this.tripId,
    this.confirmedAtUtc,
    required this.status,
    required this.statusText,
    required this.nextAction,
    required this.pickedUpBoxesCount,
    required this.totalBoxesCount,
    required this.allBoxesPickedUp,
    this.message,
  });

  final String boxId;
  final String boxCode;
  final String tripId;
  final DateTime? confirmedAtUtc;
  final String status;
  final String statusText;
  final DriverPickupNextAction nextAction;
  final int pickedUpBoxesCount;
  final int totalBoxesCount;
  final bool allBoxesPickedUp;
  final String? message;
}

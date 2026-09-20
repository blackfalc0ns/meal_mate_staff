import 'dart:io';
import 'dart:ui';

import '../../domain/entities/driver_registration_draft_entity.dart';
import '../../domain/entities/driver_resubmit_entity.dart';
import '../../domain/register_personal_data.dart';
import '../../domain/register_vehicle_data.dart';

sealed class DriverRegistrationEvent {
  const DriverRegistrationEvent();
}

class DriverRegistrationLoadRestaurantsEvent extends DriverRegistrationEvent {
  const DriverRegistrationLoadRestaurantsEvent();
}

class DriverRegistrationStepChangedEvent extends DriverRegistrationEvent {
  const DriverRegistrationStepChangedEvent(this.step);

  final int step;
}

class DriverRegistrationPersonalDataUpdatedEvent
    extends DriverRegistrationEvent {
  const DriverRegistrationPersonalDataUpdatedEvent(this.personalData);

  final RegisterPersonalData personalData;
}

class DriverRegistrationVehicleDataUpdatedEvent
    extends DriverRegistrationEvent {
  const DriverRegistrationVehicleDataUpdatedEvent({
    required this.vehicleData,
    this.selectedColor,
    this.ownsVehicle,
  });

  final RegisterVehicleData vehicleData;
  final Color? selectedColor;
  final bool? ownsVehicle;
}

class DriverRegistrationUploadDocumentEvent extends DriverRegistrationEvent {
  const DriverRegistrationUploadDocumentEvent({
    required this.documentId,
    required this.file,
  });

  final String documentId;
  final File file;
}

class DriverRegistrationRemoveDocumentEvent extends DriverRegistrationEvent {
  const DriverRegistrationRemoveDocumentEvent(this.documentId);

  final String documentId;
}

class DriverRegistrationSubmitEvent extends DriverRegistrationEvent {
  const DriverRegistrationSubmitEvent();
}

class DriverRegistrationResubmitEvent extends DriverRegistrationEvent {
  const DriverRegistrationResubmitEvent({
    required this.registrationId,
    required this.resubmitData,
  });

  final String registrationId;
  final DriverResubmitEntity resubmitData;
}

class DriverRegistrationSetDraftEvent extends DriverRegistrationEvent {
  const DriverRegistrationSetDraftEvent(this.draft);

  final DriverRegistrationDraftEntity draft;
}

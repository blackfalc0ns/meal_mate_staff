import '../../domain/entities/driver_assigned_box_entity.dart';
import '../../domain/entities/driver_box_delivery_status.dart';
import '../../domain/entities/driver_pickup_manifest_entity.dart';
import '../models/response/driver_pickup_manifest_response_dto.dart';

extension DriverPickupManifestResponseDtoMapper
    on DriverPickupManifestResponseDto {
  DriverPickupManifestEntity toEntity() {
    final rawTotalBoxes = totalBoxesCount ?? 0;
    final rawTotalMeals = totalMealsCount ?? 0;
    final rawPendingScan = pendingScanBoxesCount ?? 0;
    final rawPickedUp = pickedUpBoxesCount ?? scannedBoxesCount ?? 0;

    return DriverPickupManifestEntity(
      tripId: tripId ?? '',
      tripCode: tripCode ?? '',
      driverId: driverId ?? '',
      driverName: driverName ?? '',
      totalBoxesCount: rawTotalBoxes < 0 ? 0 : rawTotalBoxes,
      totalMealsCount: rawTotalMeals < 0 ? 0 : rawTotalMeals,
      pendingScanBoxesCount: rawPendingScan < 0 ? 0 : rawPendingScan,
      pickedUpBoxesCount: rawPickedUp < 0 ? 0 : rawPickedUp,
      allBoxesPickedUp: allBoxesPickedUp ?? false,
      canStartTrip: canStartTrip ?? false,
      boxes: boxes?.map((b) => b.toEntity()).toList() ?? const [],
    );
  }
}

extension DriverAssignedBoxResponseDtoMapper on DriverAssignedBoxResponseDto {
  DriverAssignedBoxEntity toEntity() {
    final normalizedStatus = scanStatus?.trim().toLowerCase();
    DriverBoxDeliveryStatus resolvedStatus;

    if (normalizedStatus == 'pickedup' || isScanned == true) {
      resolvedStatus = DriverBoxDeliveryStatus.pickedUp;
    } else if (normalizedStatus == 'pendingscan') {
      resolvedStatus = DriverBoxDeliveryStatus.pendingScan;
    } else if (normalizedStatus == 'barcodevalidated') {
      resolvedStatus = DriverBoxDeliveryStatus.barcodeValidated;
    } else if (normalizedStatus == 'photouploaded') {
      resolvedStatus = DriverBoxDeliveryStatus.photoUploaded;
    } else {
      resolvedStatus = DriverBoxDeliveryStatus.pendingScan;
    }

    final rawMeals = mealsCount ?? 0;
    final isPickedUp =
        resolvedStatus == DriverBoxDeliveryStatus.pickedUp ||
        (this.isScanned == true);

    DateTime? parsedDate;
    if (scannedAtUtc != null && scannedAtUtc!.trim().isNotEmpty) {
      parsedDate = DateTime.tryParse(scannedAtUtc!);
    }

    return DriverAssignedBoxEntity(
      boxId: boxId ?? '',
      boxCode: boxCode ?? '',
      customerName: customerName ?? '',
      deliveryZone: deliveryZone ?? '',
      mealsCount: rawMeals < 0 ? 0 : rawMeals,
      mealsSummary: mealsSummary ?? '',
      deliveryTimeSlot: deliveryTimeSlot ?? '',
      status: resolvedStatus,
      statusText: scanStatusText ?? '',
      isPickedUp: isPickedUp,
      scannedAtUtc: parsedDate,
      conditionPhotoStorageKey: conditionPhotoStorageKey,
    );
  }
}

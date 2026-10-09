import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../domain/entities/driver_start_delivery_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';

class ActiveDeliveryState {
  const ActiveDeliveryState({
    this.route,
    this.startResult,
    this.isStarting = false,
    this.startFailure,
    this.selectedStopId,
    this.arrivalResult,
    this.deliveryResult,
    this.localPhotoPath,
    this.photoRevision = 0,
    this.uploadedPhotoRevision,
    this.proofStorageKey,
    this.otpInput = '',
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isArriving = false,
    this.isUploading = false,
    this.isDelivering = false,
    this.loadFailure,
    this.arrivalFailure,
    this.uploadFailure,
    this.deliveryFailure,
    this.isEmpty = false,
    this.navigationRevision = 0,
    this.isEligibleToStart = false,
  });

  final DriverMapRouteEntity? route;
  final DriverStartDeliveryResultEntity? startResult;
  final bool isStarting;
  final Failure? startFailure;
  final String? selectedStopId;
  final DriverArrivalResultEntity? arrivalResult;
  final DriverDeliverResultEntity? deliveryResult;
  final String? localPhotoPath;
  final int photoRevision;
  final int? uploadedPhotoRevision;
  final String? proofStorageKey;
  final String otpInput;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isArriving;
  final bool isUploading;
  final bool isDelivering;
  final Failure? loadFailure;
  final Failure? arrivalFailure;
  final Failure? uploadFailure;
  final Failure? deliveryFailure;
  final bool isEmpty;
  final int navigationRevision;
  final bool isEligibleToStart;

  DriverMapStopEntity? get selectedStop {
    if (route == null) return null;
    if (selectedStopId != null && selectedStopId!.isNotEmpty) {
      final match = route!.stops.where(
        (s) => s.id == selectedStopId || s.boxId == selectedStopId,
      );
      if (match.isNotEmpty) return match.first;
    }
    return route!.focusedStop.id.isNotEmpty
        ? route!.focusedStop
        : (route!.stops.isNotEmpty ? route!.stops.first : null);
  }

  bool get hasArrived {
    final stop = selectedStop;
    return arrivalResult != null || (stop != null && stop.arrivedAtUtc != null);
  }

  DateTime? get effectiveArrivedAtUtc {
    return arrivalResult?.arrivedAtUtc ?? selectedStop?.arrivedAtUtc;
  }

  bool get isProofUploaded {
    return (proofStorageKey?.trim().isNotEmpty ?? false) &&
        uploadedPhotoRevision == photoRevision;
  }

  bool get canDeliver {
    final stop = selectedStop;
    return !isArriving &&
        !isUploading &&
        !isDelivering &&
        stop != null &&
        stop.status != DriverDeliveryStatus.delivered &&
        hasArrived &&
        isProofUploaded;
  }

  ActiveDeliveryState copyWith({
    DriverStartDeliveryResultEntity? startResult,
    bool clearStartResult = false,
    bool? isStarting,
    Failure? startFailure,
    bool clearStartFailure = false,
    DriverMapRouteEntity? route,
    bool clearRoute = false,
    String? selectedStopId,
    bool clearSelectedStopId = false,
    DriverArrivalResultEntity? arrivalResult,
    bool clearArrivalResult = false,
    DriverDeliverResultEntity? deliveryResult,
    bool clearDeliveryResult = false,
    String? localPhotoPath,
    bool clearLocalPhotoPath = false,
    int? photoRevision,
    int? uploadedPhotoRevision,
    bool clearUploadedPhotoRevision = false,
    String? proofStorageKey,
    bool clearProofStorageKey = false,
    String? otpInput,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isArriving,
    bool? isUploading,
    bool? isDelivering,
    Failure? loadFailure,
    bool clearLoadFailure = false,
    Failure? arrivalFailure,
    bool clearArrivalFailure = false,
    Failure? uploadFailure,
    bool clearUploadFailure = false,
    Failure? deliveryFailure,
    bool clearDeliveryFailure = false,
    bool? isEmpty,
    int? navigationRevision,
    bool? isEligibleToStart,
  }) {
    return ActiveDeliveryState(
      startResult: clearStartResult ? null : (startResult ?? this.startResult),
      isStarting: isStarting ?? this.isStarting,
      startFailure: clearStartFailure
          ? null
          : (startFailure ?? this.startFailure),
      route: clearRoute ? null : (route ?? this.route),
      selectedStopId: clearSelectedStopId
          ? null
          : (selectedStopId ?? this.selectedStopId),
      arrivalResult: clearArrivalResult
          ? null
          : (arrivalResult ?? this.arrivalResult),
      deliveryResult: clearDeliveryResult
          ? null
          : (deliveryResult ?? this.deliveryResult),
      localPhotoPath: clearLocalPhotoPath
          ? null
          : (localPhotoPath ?? this.localPhotoPath),
      photoRevision: photoRevision ?? this.photoRevision,
      uploadedPhotoRevision: clearUploadedPhotoRevision
          ? null
          : (uploadedPhotoRevision ?? this.uploadedPhotoRevision),
      proofStorageKey: clearProofStorageKey
          ? null
          : (proofStorageKey ?? this.proofStorageKey),
      otpInput: otpInput ?? this.otpInput,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isArriving: isArriving ?? this.isArriving,
      isUploading: isUploading ?? this.isUploading,
      isDelivering: isDelivering ?? this.isDelivering,
      loadFailure: clearLoadFailure ? null : (loadFailure ?? this.loadFailure),
      arrivalFailure: clearArrivalFailure
          ? null
          : (arrivalFailure ?? this.arrivalFailure),
      uploadFailure: clearUploadFailure
          ? null
          : (uploadFailure ?? this.uploadFailure),
      deliveryFailure: clearDeliveryFailure
          ? null
          : (deliveryFailure ?? this.deliveryFailure),
      isEmpty: isEmpty ?? this.isEmpty,
      navigationRevision: navigationRevision ?? this.navigationRevision,
      isEligibleToStart: isEligibleToStart ?? this.isEligibleToStart,
    );
  }
}

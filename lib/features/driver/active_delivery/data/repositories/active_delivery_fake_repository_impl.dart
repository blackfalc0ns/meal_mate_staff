import 'dart:async';

import '../../domain/entities/active_delivery_location_entity.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/entities/delivery_trip_status.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../../domain/repositories/active_delivery_repository.dart';

class ActiveDeliveryFakeRepositoryImpl implements ActiveDeliveryRepository {
  ActiveDeliveryFakeRepositoryImpl({
    ActiveDeliveryTripEntity? initialTrip,
    Duration locationTickInterval = const Duration(seconds: 3),
  }) : _currentTrip = initialTrip ?? DriverActiveDeliveryFakeData.defaultTrip,
       _tickInterval = locationTickInterval {
    _locationController =
        StreamController<ActiveDeliveryLocationEntity>.broadcast(
          onListen: _onStreamListened,
          onCancel: _onStreamCancelled,
        );
  }

  ActiveDeliveryTripEntity _currentTrip;
  final Duration _tickInterval;
  late final StreamController<ActiveDeliveryLocationEntity> _locationController;
  Timer? _locationTimer;
  int _routeIndex = 0;

  @override
  Future<ActiveDeliveryTripEntity> getActiveTrip() async {
    return _currentTrip;
  }

  @override
  Stream<ActiveDeliveryLocationEntity> watchDriverLocation() {
    return _locationController.stream;
  }

  void _onStreamListened() {
    if (_currentTrip.status == DeliveryTripStatus.enRoute ||
        _currentTrip.status == DeliveryTripStatus.readyToStart) {
      _startEmittingLocation();
    }
  }

  void _onStreamCancelled() {
    if (!_locationController.hasListener) {
      _stopEmittingLocation();
    }
  }

  void _startEmittingLocation() {
    _locationTimer?.cancel();
    if (_locationController.isClosed) return;

    // Emit initial location immediately
    _locationController.add(_currentTrip.driverLocation);

    _locationTimer = Timer.periodic(_tickInterval, (timer) {
      if (_locationController.isClosed) {
        timer.cancel();
        return;
      }
      final points = _currentTrip.routePoints;
      if (points.isEmpty) return;

      _routeIndex = (_routeIndex + 1) % points.length;
      final nextLocation = points[_routeIndex];
      _currentTrip = _currentTrip.copyWith(driverLocation: nextLocation);
      _locationController.add(nextLocation);
    });
  }

  void _stopEmittingLocation() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  Future<void> startDeliveryRoute(String tripId) async {
    _currentTrip = _currentTrip.copyWith(
      status: DeliveryTripStatus.enRoute,
      startedAt: DateTime.now(),
    );
    _startEmittingLocation();
  }

  @override
  Future<void> markArrivedAtCustomer(String tripId) async {
    _stopEmittingLocation();
    _currentTrip = _currentTrip.copyWith(
      status: DeliveryTripStatus.arrived,
      arrivedAt: DateTime.now(),
      driverLocation: _currentTrip.customerLocation,
    );
    if (!_locationController.isClosed) {
      _locationController.add(_currentTrip.customerLocation);
    }
  }

  @override
  Future<void> completeDelivery(String tripId) async {
    _stopEmittingLocation();
    _currentTrip = _currentTrip.copyWith(
      status: DeliveryTripStatus.delivered,
      deliveredAt: DateTime.now(),
    );
  }

  @override
  Future<void> reportDeliveryDelay(String tripId, String reason) async {
    _currentTrip = _currentTrip.copyWith(
      status: DeliveryTripStatus.delayed,
      delayReason: reason,
    );
  }

  @override
  Future<void> reportDeliveryFailed(
    String tripId,
    String reasonId,
    String? note,
  ) async {
    _stopEmittingLocation();
    final reasonEntity = DriverActiveDeliveryFakeData.failureReasons.firstWhere(
      (r) => r.id == reasonId,
      orElse: () => DriverActiveDeliveryFakeData.failureReasons.last,
    );

    final returnBox = DriverActiveDeliveryFakeData.createReturnBox(
      failureReason: reasonEntity.title,
      note: note,
    );

    _currentTrip = _currentTrip.copyWith(
      status: DeliveryTripStatus.failed,
      failureReason: reasonEntity,
      returnBox: returnBox,
      routePoints: DriverActiveDeliveryFakeData.returnRoutePoints,
    );
  }

  @override
  Future<void> confirmBoxReturnedToRestaurant(String tripId) async {
    _stopEmittingLocation();
    _currentTrip = _currentTrip.copyWith(
      status: DeliveryTripStatus.boxReturned,
      driverLocation: _currentTrip.restaurantLocation,
    );
  }

  @override
  void dispose() {
    _stopEmittingLocation();
    unawaited(_locationController.close());
  }
}

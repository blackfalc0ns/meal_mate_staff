import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_realtime_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';
import 'package:meal_mate_delivery/features/driver/tracking/data/datasources/driver_location_remote_datasource.dart';
import 'package:meal_mate_delivery/features/driver/tracking/data/services/driver_location_service.dart';
import 'package:meal_mate_delivery/features/driver/tracking/domain/entities/driver_live_location_sample.dart';

class DriverLiveLocationCoordinator {
  DriverLiveLocationCoordinator({
    required this.locationService,
    required this.realtimeClient,
    required this.fallbackDataSource,
    this.streamingInterval = const Duration(seconds: 4),
  }) {
    _initRealtimeListeners();
    _log('Status: IDLE | Coordinator ready (waiting for active deliveries)');
  }

  final DriverLocationService locationService;
  final DriverOrdersRealtimeClient realtimeClient;
  final DriverLocationRemoteDataSource fallbackDataSource;
  final Duration streamingInterval;

  Timer? _streamingTimer;
  StreamSubscription<DriverOrdersRealtimeEvent>? _realtimeSubscription;
  StreamSubscription<Position>? _positionSubscription;

  Position? _latestPosition;
  DriverLiveLocationSample? _latestLocationSample;
  DriverLiveLocationSample? _lastSuccessfullySentLocation;
  int _activeBoxCount = 0;
  bool _isStreaming = false;
  bool _isDisposed = false;
  bool _isSending = false;
  Future<bool>? _inFlightSendFuture;

  final _streamingStatusController = StreamController<bool>.broadcast();
  final _positionsController = StreamController<DriverLiveLocationSample>.broadcast();

  bool get isStreaming => _isStreaming;
  int get activeBoxCount => _activeBoxCount;
  Stream<bool> get streamingStatusStream => _streamingStatusController.stream;
  Stream<DriverLiveLocationSample> get positions => _positionsController.stream;
  DriverLiveLocationSample? get latestLocation => _latestLocationSample;
  DriverLiveLocationSample? get lastSuccessfullySentLocation => _lastSuccessfullySentLocation;

  void _log(String message, {Object? error}) {
    developer.log(message, name: 'DriverLiveTracking', error: error);
    debugPrint('[DriverLiveTracking] $message');
  }

  void _initRealtimeListeners() {
    _realtimeSubscription = realtimeClient.events.listen((event) {
      if (_isDisposed) return;

      if (event is DriverBoxAssignedEvent) {
        _log('📦 Box assigned received (boxId: ${event.boxId}, reassigned: ${event.isReassigned})');
        _activeBoxCount = math.max(1, _activeBoxCount + 1);
        unawaited(startTracking());
      } else if (event is DriverDeliveryCompletedEvent) {
        _log('🏁 Delivery completed received (boxId: ${event.boxId}, remaining: ${event.remainingBoxesCount})');
        if (event.remainingBoxesCount != null) {
          _activeBoxCount = event.remainingBoxesCount!;
        } else {
          _activeBoxCount = math.max(0, _activeBoxCount - 1);
        }
        if (_activeBoxCount <= 0) {
          _log('No remaining active boxes. Stopping tracking.');
          stopTracking(reason: 'all_deliveries_completed');
        }
      } else if (event is DriverOrderDeliveredEvent) {
        _log('✅ Box delivered event received: ${event.boxId}');
        _activeBoxCount = math.max(0, _activeBoxCount - 1);
        if (_activeBoxCount <= 0) {
          stopTracking(reason: 'all_deliveries_completed');
        }
      } else if (event is DriverTrackingNotRequiredEvent) {
        _log('🛑 Server reported dispatcher.tracking_not_required. Immediate halt!');
        _activeBoxCount = 0;
        stopTracking(reason: 'server_tracking_not_required');
      }
    });
  }

  /// Sets the active boxes count and starts or stops streaming accordingly.
  Future<void> setActiveBoxesCount(int count) async {
    if (_isDisposed) return;
    _activeBoxCount = math.max(0, count);
    if (_activeBoxCount > 0 && !_isStreaming) {
      _log('Status: STARTING stream | Active boxes: $_activeBoxCount');
      await startTracking();
    } else if (_activeBoxCount == 0 && _isStreaming) {
      _log('Status: STOPPING stream | Active boxes: 0');
      stopTracking(reason: 'zero_active_boxes');
    } else {
      _log('Status: ${_isStreaming ? "STREAMING" : "IDLE"} | Active boxes: $_activeBoxCount');
    }
  }

  /// Starts the location streaming loop if active boxes exist.
  Future<void> startTracking() async {
    if (_isDisposed) return;
    if (_isStreaming) return;

    if (_activeBoxCount <= 0) {
      _log('Status: IDLE | Cannot start streaming: No active deliveries assigned (_activeBoxCount: 0)');
      return;
    }

    final hasPermission = await locationService.checkAndRequestPermission();
    if (!hasPermission) {
      _log('Status: BLOCKED | Cannot start streaming: Location permission not granted');
      return;
    }

    _isStreaming = true;
    _streamingStatusController.add(true);
    _log('Status: STREAMING ACTIVE | Interval: ${streamingInterval.inSeconds}s | Active boxes: $_activeBoxCount');

    // Ensure SignalR connection is started
    try {
      await realtimeClient.start();
    } catch (e) {
      _log('SignalR connection note: $e');
    }

    // Subscribe to continuous GPS position stream
    await _positionSubscription?.cancel();
    _positionSubscription = locationService
        .getPositionStream(intervalSeconds: streamingInterval.inSeconds)
        .listen(
      (pos) {
        _latestPosition = pos;
        final sample = DriverLiveLocationSample(
          latitude: pos.latitude,
          longitude: pos.longitude,
          recordedAtUtc: pos.timestamp.toUtc(),
          heading: pos.heading >= 0 && pos.heading <= 360 ? pos.heading : null,
          speedKmh: pos.speed >= 0 ? pos.speed * 3.6 : null,
        );
        _latestLocationSample = sample;
        if (!_positionsController.isClosed) {
          _positionsController.add(sample);
        }
      },
      onError: (err) {
        _log('GPS Stream error: $err', error: err);
      },
    );

    // Immediate first tick
    await _sendTick();

    // Periodic sending loop
    _streamingTimer?.cancel();
    _streamingTimer = Timer.periodic(streamingInterval, (_) {
      unawaited(_sendTick());
    });
  }

  /// Sends the current location immediately or waits for an ongoing send operation.
  Future<bool> sendCurrentLocationNow() async {
    if (_isDisposed) return false;
    if (_inFlightSendFuture != null) {
      return _inFlightSendFuture!;
    }

    final completer = Completer<bool>();
    _inFlightSendFuture = completer.future;

    try {
      bool success = false;
      if (!_isStreaming) {
        if (_activeBoxCount > 0) {
          await startTracking();
          success = _lastSuccessfullySentLocation != null;
        } else {
          final hasPermission = await locationService.checkAndRequestPermission();
          if (hasPermission) {
            success = await _sendTick();
          }
        }
      } else {
        success = await _sendTick();
      }
      completer.complete(success);
      return success;
    } catch (e) {
      completer.complete(false);
      return false;
    } finally {
      _inFlightSendFuture = null;
    }
  }

  Future<bool> _sendTick() async {
    if (_isDisposed || _isSending) return false;
    _isSending = true;
    bool sentSuccessfully = false;

    try {
      Position? position = _latestPosition;
      if (position == null) {
        position = await locationService.getCurrentPosition();
        if (position != null) {
          _latestPosition = position;
          _latestLocationSample = DriverLiveLocationSample(
            latitude: position.latitude,
            longitude: position.longitude,
            recordedAtUtc: position.timestamp.toUtc(),
            heading: position.heading >= 0 && position.heading <= 360 ? position.heading : null,
            speedKmh: position.speed >= 0 ? position.speed * 3.6 : null,
          );
          if (!_positionsController.isClosed) {
            _positionsController.add(_latestLocationSample!);
          }
        }
      }

      if (position == null) {
        _log('⏳ Waiting for GPS fix...');
        return false;
      }

      final lat = position.latitude;
      final lng = position.longitude;

      if (!DriverLocationServiceImpl.isValidCoordinate(lat, lng)) {
        _log('⚠️ Skipping invalid coordinates ($lat, $lng)');
        return false;
      }

      final heading = position.heading >= 0 && position.heading <= 360
          ? position.heading
          : null;
      // Convert speed from m/s to km/h
      final speedKmh = position.speed >= 0 ? position.speed * 3.6 : null;

      // 1. Primary path: SignalR Hub
      if (realtimeClient.isConnected) {
        try {
          await realtimeClient.updateLocation(
            latitude: lat,
            longitude: lng,
            heading: heading,
            speedKmh: speedKmh,
          );
          sentSuccessfully = true;
          _log('Sent [SignalR] -> Lat: $lat, Lng: $lng | Speed: ${speedKmh?.toStringAsFixed(1) ?? "0.0"} km/h | Heading: ${heading?.toStringAsFixed(1) ?? "0.0"}°');
        } catch (hubErr) {
          final errStr = hubErr.toString().toLowerCase();
          if (errStr.contains('dispatcher.tracking_not_required') ||
              errStr.contains('tracking_not_required')) {
            _activeBoxCount = 0;
            stopTracking(reason: 'dispatcher.tracking_not_required');
            return false;
          }
          _log('SignalR updateLocation failed: $hubErr. Falling back to REST...');
        }
      }

      // 2. Fallback path: REST API if SignalR failed or disconnected
      if (!sentSuccessfully) {
        try {
          await fallbackDataSource.sendLocation(
            latitude: lat,
            longitude: lng,
            heading: heading,
            speedKmh: speedKmh,
          );
          sentSuccessfully = true;
          _log('Sent [REST API] -> Lat: $lat, Lng: $lng | Speed: ${speedKmh?.toStringAsFixed(1) ?? "0.0"} km/h | Heading: ${heading?.toStringAsFixed(1) ?? "0.0"}°');
        } on DioException catch (dioErr) {
          final statusCode = dioErr.response?.statusCode;
          final responseBody = dioErr.response?.data?.toString().toLowerCase() ?? '';
          if (statusCode == 409 || responseBody.contains('tracking_not_required')) {
            _log('REST 409 tracking_not_required. Halting stream.');
            _activeBoxCount = 0;
            stopTracking(reason: 'dispatcher.tracking_not_required');
            return false;
          }
          _log('REST fallback failed: ${dioErr.message}');
        } catch (e) {
          _log('REST fallback unexpected error: $e');
        }
      }

      if (sentSuccessfully) {
        _lastSuccessfullySentLocation = DriverLiveLocationSample(
          latitude: lat,
          longitude: lng,
          recordedAtUtc: position.timestamp.toUtc(),
          heading: heading,
          speedKmh: speedKmh,
        );
      }
      return sentSuccessfully;
    } finally {
      _isSending = false;
    }
  }

  /// Stops streaming and releases GPS listeners.
  void stopTracking({String? reason}) {
    if (!_isStreaming) return;
    _isStreaming = false;
    _streamingTimer?.cancel();
    _streamingTimer = null;
    if (_positionSubscription != null) {
      unawaited(_positionSubscription!.cancel());
      _positionSubscription = null;
    }
    _latestPosition = null;

    if (!_streamingStatusController.isClosed) {
      _streamingStatusController.add(false);
    }
    _log('Status: STREAMING STOPPED | Reason: ${reason ?? "manual"}');
  }

  void dispose() {
    _isDisposed = true;
    stopTracking(reason: 'disposed');
    if (_realtimeSubscription != null) {
      unawaited(_realtimeSubscription!.cancel());
    }
    unawaited(_streamingStatusController.close());
    unawaited(_positionsController.close());
  }
}

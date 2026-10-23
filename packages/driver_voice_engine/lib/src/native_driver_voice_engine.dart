import 'dart:async';

import '../driver_voice_engine.dart';
import 'generated/driver_voice_api.g.dart';

abstract class DriverVoiceHostBridge {
  Future<DriverVoiceEngineCapabilities> getCapabilities();
  Future<DriverVoiceCallSnapshot?> getCurrentCall();
  Future<DriverVoiceCommandResult> startOutgoing(
    DriverVoiceStartOutgoingRequest request,
  );
  Future<DriverVoiceCommandResult> setMuted(bool muted);
  Future<DriverVoiceCommandResult> selectAudioRoute(
    DriverVoiceAudioRoute route,
  );
  Future<DriverVoiceCommandResult> hangUp(String? reason);
  Future<DriverVoiceCommandResult> syncAccountSession(
    DriverVoiceAccountSession session,
  );
  Future<DriverVoiceCommandResult> revokeAccountSession();
}

class DefaultDriverVoiceHostBridge implements DriverVoiceHostBridge {
  DefaultDriverVoiceHostBridge([DriverVoiceHostApi? api])
      : _api = api ?? DriverVoiceHostApi();

  final DriverVoiceHostApi _api;

  @override
  Future<DriverVoiceEngineCapabilities> getCapabilities() =>
      _api.getCapabilities();

  @override
  Future<DriverVoiceCallSnapshot?> getCurrentCall() => _api.getCurrentCall();

  @override
  Future<DriverVoiceCommandResult> startOutgoing(
    DriverVoiceStartOutgoingRequest request,
  ) =>
      _api.startOutgoing(request);

  @override
  Future<DriverVoiceCommandResult> setMuted(bool muted) =>
      _api.setMuted(muted);

  @override
  Future<DriverVoiceCommandResult> selectAudioRoute(
    DriverVoiceAudioRoute route,
  ) =>
      _api.selectAudioRoute(route);

  @override
  Future<DriverVoiceCommandResult> hangUp(String? reason) =>
      _api.hangUp(reason);

  @override
  Future<DriverVoiceCommandResult> syncAccountSession(
    DriverVoiceAccountSession session,
  ) =>
      _api.syncAccountSession(session);

  @override
  Future<DriverVoiceCommandResult> revokeAccountSession() =>
      _api.revokeAccountSession();
}

class NativeDriverVoiceEngine implements DriverVoiceEngine {
  NativeDriverVoiceEngine({
    DriverVoiceHostBridge? hostBridge,
  }) : _hostBridge = hostBridge ?? DefaultDriverVoiceHostBridge() {
    _handler = _DriverVoiceFlutterApiHandler(this);
    DriverVoiceFlutterApi.setUp(_handler);
  }

  static NativeDriverVoiceEngine? _instance;
  static NativeDriverVoiceEngine get instance =>
      _instance ??= NativeDriverVoiceEngine();

  final DriverVoiceHostBridge _hostBridge;
  late final _DriverVoiceFlutterApiHandler _handler;

  final _snapshotController =
      StreamController<DriverVoiceCallSnapshot>.broadcast();
  final _commandAckController =
      StreamController<DriverVoiceCommandResult>.broadcast();

  DriverVoiceCallSnapshot? _lastSnapshot;
  String? _lastEngineInstanceId;
  int _lastLocalRevision = -1;

  @override
  Stream<DriverVoiceCallSnapshot> get onSnapshotUpdated =>
      _snapshotController.stream;

  @override
  Stream<DriverVoiceCommandResult> get onCommandAcknowledged =>
      _commandAckController.stream;

  DriverVoiceCallSnapshot? get currentCachedSnapshot => _lastSnapshot;

  @override
  Future<DriverVoiceEngineCapabilities> getCapabilities() async {
    return _hostBridge.getCapabilities();
  }

  @override
  Future<DriverVoiceCallSnapshot?> getCurrentCall() async {
    final snapshot = await _hostBridge.getCurrentCall();
    if (snapshot != null) {
      handleSnapshotUpdated(snapshot);
    }
    return _lastSnapshot;
  }

  @override
  Future<DriverVoiceCommandResult> startOutgoing({
    required String tripStopId,
    required String clientRequestId,
    DriverVoiceCallDisplayMetadata? displayMetadata,
  }) async {
    final req = DriverVoiceStartOutgoingRequest(
      tripStopId: tripStopId,
      clientRequestId: clientRequestId,
      displayMetadata: displayMetadata,
    );
    return _hostBridge.startOutgoing(req);
  }

  @override
  Future<DriverVoiceCommandResult> setMuted(bool muted) async {
    return _hostBridge.setMuted(muted);
  }

  @override
  Future<DriverVoiceCommandResult> selectAudioRoute(
    DriverVoiceAudioRoute route,
  ) async {
    return _hostBridge.selectAudioRoute(route);
  }

  @override
  Future<DriverVoiceCommandResult> hangUp([String? reason]) async {
    return _hostBridge.hangUp(reason);
  }

  @override
  Future<DriverVoiceCommandResult> syncAccountSession(
    DriverVoiceAccountSession session,
  ) async {
    return _hostBridge.syncAccountSession(session);
  }

  @override
  Future<DriverVoiceCommandResult> revokeAccountSession() async {
    return _hostBridge.revokeAccountSession();
  }

  void handleSnapshotUpdated(DriverVoiceCallSnapshot snapshot) {
    // If engineInstanceId changed, resync regardless of revision
    if (_lastEngineInstanceId != snapshot.engineInstanceId) {
      _lastEngineInstanceId = snapshot.engineInstanceId;
      _lastLocalRevision = snapshot.localRevision;
      _lastSnapshot = snapshot;
      _snapshotController.add(snapshot);
      return;
    }

    // Discard older revisions from the same engine instance
    if (snapshot.localRevision < _lastLocalRevision) {
      return;
    }

    _lastLocalRevision = snapshot.localRevision;
    _lastSnapshot = snapshot;
    _snapshotController.add(snapshot);
  }

  void handleCommandAcknowledged(DriverVoiceCommandResult result) {
    _commandAckController.add(result);
  }

  void dispose() {
    _snapshotController.close();
    _commandAckController.close();
  }
}

class _DriverVoiceFlutterApiHandler implements DriverVoiceFlutterApi {
  _DriverVoiceFlutterApiHandler(this._engine);

  final NativeDriverVoiceEngine _engine;

  @override
  void onSnapshotUpdated(DriverVoiceCallSnapshot snapshot) {
    _engine.handleSnapshotUpdated(snapshot);
  }

  @override
  void onCommandAcknowledged(DriverVoiceCommandResult result) {
    _engine.handleCommandAcknowledged(result);
  }
}

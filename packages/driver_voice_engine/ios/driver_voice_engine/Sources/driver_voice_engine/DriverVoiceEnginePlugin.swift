import Flutter
import UIKit
import AVFoundation

public class DriverVoiceEnginePlugin: NSObject, FlutterPlugin, DriverVoiceHostApi {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = DriverVoiceEnginePlugin()
        DriverVoiceHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        NativeCallCoordinator.shared.flutterApi = DriverVoiceFlutterApi(binaryMessenger: registrar.messenger())
    }

    func getCapabilities() throws -> DriverVoiceEngineCapabilities {
        return DriverVoiceEngineCapabilities(
            supportsTelecom: false,
            supportsCallKit: true,
            supportsProximity: true,
            supportsBluetoothRouting: true
        )
    }

    func getCurrentCall() throws -> DriverVoiceCallSnapshot? {
        let snapshot = NativeCallCoordinator.shared.getCurrentSnapshot()
        if snapshot.serverStatus != .idle {
            return snapshot
        }
        return nil
    }

    func startOutgoing(
        request: DriverVoiceStartOutgoingRequest,
        completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void
    ) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completion(.success(DriverVoiceCommandResult(status: .preparationFailed, errorMessage: "Microphone permission is required for voice calls")))
                    return
                }
                NativeCallCoordinator.shared.startOutgoing(request: request, completion: completion)
            }
        }
    }

    func setMuted(
        muted: Bool,
        completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void
    ) {
        NativeCallCoordinator.shared.setMuted(muted: muted, completion: completion)
    }

    func selectAudioRoute(
        route: DriverVoiceAudioRoute,
        completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void
    ) {
        NativeCallCoordinator.shared.selectAudioRoute(route: route, completion: completion)
    }

    func hangUp(
        reason: String?,
        completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void
    ) {
        NativeCallCoordinator.shared.hangUp(reason: reason, completion: completion)
    }

    func syncAccountSession(
        session: DriverVoiceAccountSession,
        completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void
    ) {
        NativeCallCoordinator.shared.store.saveAccountSession(session)
        completion(.success(DriverVoiceCommandResult(status: .success, errorMessage: nil, operationId: nil)))
    }

    func revokeAccountSession(
        completion: @escaping (Result<DriverVoiceCommandResult, Error>) -> Void
    ) {
        NativeCallCoordinator.shared.hangUp(reason: "account_revoked")
        NativeCallCoordinator.shared.store.clearAll()
        NativeCallCoordinator.shared.signalRClient.disconnect()
        completion(.success(DriverVoiceCommandResult(status: .success, errorMessage: nil, operationId: nil)))
    }
}


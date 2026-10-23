import Foundation

class VoiceCallStore {
    static let shared = VoiceCallStore()

    private let defaults = UserDefaults.standard
    private let lock = NSLock()

    private let keyAccessToken = "mealmate_voice_access_token"
    private let keyRefreshToken = "mealmate_voice_refresh_token"
    private let keyUserId = "mealmate_voice_user_id"
    private let keyBaseUrl = "mealmate_voice_base_url"
    private let keyHubUrl = "mealmate_voice_hub_url"
    private let keyInstallationId = "mealmate_voice_installation_id"
    private let keyFcmDeviceTokenId = "mealmate_voice_fcm_device_token_id"
    private let keyApnsVoipToken = "mealmate_voice_apns_voip_token"

    private let keyDeviceSessionId = "mealmate_voice_device_session_id"
    private let keyControlProof = "mealmate_voice_control_proof"
    private let keyExpiresAtUtc = "mealmate_voice_expires_at_utc"

    private let keyLastCallId = "mealmate_voice_last_call_id"
    private let keyLastTripStopId = "mealmate_voice_last_trip_stop_id"
    private let keyLastClientRequestId = "mealmate_voice_last_client_request_id"
    private let keyServerEndPending = "mealmate_voice_server_end_pending"

    init() {}

    func saveAccountSession(_ session: DriverVoiceAccountSession) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(session.accessToken, forKey: keyAccessToken)
        defaults.set(session.refreshToken, forKey: keyRefreshToken)
        defaults.set(session.userId, forKey: keyUserId)
        defaults.set(session.baseUrl, forKey: keyBaseUrl)
        defaults.set(session.hubUrl, forKey: keyHubUrl)
        defaults.set(session.installationId, forKey: keyInstallationId)
        defaults.set(session.fcmDeviceTokenId, forKey: keyFcmDeviceTokenId)
        defaults.set(session.apnsVoipToken, forKey: keyApnsVoipToken)
    }

    func getAccessToken() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyAccessToken)
    }

    func setAccessToken(_ token: String) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(token, forKey: keyAccessToken)
    }

    func getRefreshToken() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyRefreshToken)
    }

    func setRefreshToken(_ token: String?) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(token, forKey: keyRefreshToken)
    }

    func getBaseUrl() -> String {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyBaseUrl) ?? "https://api.trymealmate.com"
    }

    func getHubUrl() -> String {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyHubUrl) ?? "\(getBaseUrl())/hubs/voice-call-v2"
    }

    func getInstallationId() -> String {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyInstallationId) ?? "voice-device-ios"
    }

    func getFcmDeviceTokenId() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyFcmDeviceTokenId)
    }

    func getApnsVoipToken() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyApnsVoipToken)
    }

    func saveDeviceSession(sessionId: String, proof: String, expiresAtUtc: String) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(sessionId, forKey: keyDeviceSessionId)
        defaults.set(proof, forKey: keyControlProof)
        defaults.set(expiresAtUtc, forKey: keyExpiresAtUtc)
    }

    func getDeviceSessionId() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyDeviceSessionId)
    }

    func getControlProof() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyControlProof)
    }

    func getExpiresAtUtc() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: keyExpiresAtUtc)
    }

    func clearDeviceSession() {
        lock.lock()
        defer { lock.unlock() }
        defaults.removeObject(forKey: keyDeviceSessionId)
        defaults.removeObject(forKey: keyControlProof)
        defaults.removeObject(forKey: keyExpiresAtUtc)
    }

    func saveCallReconciliation(callId: String, tripStopId: String, clientRequestId: String, endPending: BooleanLiteralType) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(callId, forKey: keyLastCallId)
        defaults.set(tripStopId, forKey: keyLastTripStopId)
        defaults.set(clientRequestId, forKey: keyLastClientRequestId)
        defaults.set(endPending, forKey: keyServerEndPending)
    }

    func isServerEndPending() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return defaults.bool(forKey: keyServerEndPending)
    }

    func setServerEndPending(_ pending: Bool) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(pending, forKey: keyServerEndPending)
    }

    func clearCallReconciliation() {
        lock.lock()
        defer { lock.unlock() }
        defaults.removeObject(forKey: keyLastCallId)
        defaults.removeObject(forKey: keyLastTripStopId)
        defaults.removeObject(forKey: keyLastClientRequestId)
        defaults.removeObject(forKey: keyServerEndPending)
    }

    func clearAll() {
        lock.lock()
        defer { lock.unlock() }
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
    }
}


import Foundation

class VoiceSessionManager {
    private let store: VoiceCallStore
    private let apiClient: VoiceAPIClient

    init(store: VoiceCallStore, apiClient: VoiceAPIClient) {
        self.store = store
        self.apiClient = apiClient
    }

    func isSessionValid() -> Bool {
        guard let sessionId = store.getDeviceSessionId(), !sessionId.isEmpty,
              let proof = store.getControlProof(), !proof.isEmpty,
              let expiresAtUtc = store.getExpiresAtUtc(), !expiresAtUtc.isEmpty else {
            return false
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: expiresAtUtc)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: expiresAtUtc)
        }
        guard let expiryDate = date else { return false }

        // 60-second safety margin
        return expiryDate.timeIntervalSinceNow > 60
    }

    func ensureSession(completion: @escaping (Bool) -> Void) {
        if isSessionValid() {
            completion(true)
            return
        }

        guard let fcmTokenId = store.getFcmDeviceTokenId(), !fcmTokenId.isEmpty else {
            completion(false)
            return
        }

        let installationId = store.getInstallationId()
        let apnsVoipToken = store.getApnsVoipToken()

        apiClient.registerDevice(
            fcmDeviceTokenId: fcmTokenId,
            installationId: installationId,
            platform: "ios",
            apnsVoipToken: apnsVoipToken,
            capabilityVersion: 2
        ) { [weak self] result in
            guard let self = self else {
                completion(false)
                return
            }
            switch result {
            case .success(let response):
                if !response.deviceSessionId.isEmpty {
                    self.store.saveDeviceSession(
                        sessionId: response.deviceSessionId,
                        proof: response.controlProof,
                        expiresAtUtc: response.expiresAtUtc
                    )
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }

    func getVoiceHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        if let token = store.getAccessToken(), !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        if let sessionId = store.getDeviceSessionId(), !sessionId.isEmpty {
            headers["X-Voice-Device-Session"] = sessionId
        }
        if let proof = store.getControlProof(), !proof.isEmpty {
            headers["X-Voice-Device-Proof"] = proof
        }
        return headers
    }
}


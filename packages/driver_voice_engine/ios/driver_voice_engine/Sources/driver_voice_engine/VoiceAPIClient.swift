import Foundation

struct IOSDeviceRegisterResponse {
    let deviceSessionId: String
    let controlProof: String
    let expiresAtUtc: String
}

struct IOSCallSnapshotResponse {
    let callId: String
    let tripStopId: String
    let status: String
    let sequence: Int
    let startedAtUtc: String?
    let acceptedAtUtc: String?
    let connectedAtUtc: String?
    let endedAtUtc: String?
    let durationSeconds: Int?
    let deadlineAtUtc: String?
    let endReason: String?
}

struct IOSIceServer {
    let urls: [String]
    let username: String?
    let credential: String?
}

class VoiceAPIClient {
    private let store: VoiceCallStore
    private let session: URLSession

    init(store: VoiceCallStore) {
        self.store = store
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 15.0
        self.session = URLSession(configuration: config)
    }

    func refreshJwt(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = store.getRefreshToken(), !refreshToken.isEmpty else {
            completion(false)
            return
        }

        let baseUrl = store.getBaseUrl()
        guard let url = URL(string: "\(baseUrl)/api/v1/auth/refresh") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["refreshToken": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, error == nil,
                  let http = response as? HTTPURLResponse,
                  http.statusCode == 200,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccessToken = json["accessToken"] as? String, !newAccessToken.isEmpty else {
                completion(false)
                return
            }

            self.store.setAccessToken(newAccessToken)
            if let newRefreshToken = json["refreshToken"] as? String, !newRefreshToken.isEmpty {
                self.store.setRefreshToken(newRefreshToken)
            }
            completion(true)
        }.resume()
    }

    func registerDevice(
        fcmDeviceTokenId: String,
        installationId: String,
        platform: String,
        apnsVoipToken: String? = nil,
        capabilityVersion: Int = 2,
        completion: @escaping (Result<IOSDeviceRegisterResponse, Error>) -> Void
    ) {
        let baseUrl = store.getBaseUrl()
        guard let url = URL(string: "\(baseUrl)/api/v2/voice-calls/devices/register") else {
            completion(.failure(PigeonError(code: "invalid_url", message: "Invalid URL", details: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = store.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body: [String: Any] = [
            "installationId": installationId,
            "platform": platform,
            "fcmDeviceTokenId": fcmDeviceTokenId,
            "capabilityVersion": capabilityVersion
        ]
        if let voip = apnsVoipToken, !voip.isEmpty {
            body["apnsVoipToken"] = voip
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(PigeonError(code: "network_error", message: "No response", details: nil)))
                return
            }

            if http.statusCode == 401 {
                self?.refreshJwt { success in
                    if success {
                        self?.registerDevice(
                            fcmDeviceTokenId: fcmDeviceTokenId,
                            installationId: installationId,
                            platform: platform,
                            apnsVoipToken: apnsVoipToken,
                            capabilityVersion: capabilityVersion,
                            completion: completion
                        )
                    } else {
                        completion(.failure(PigeonError(code: "unauthorized", message: "401 Unauthorized", details: nil)))
                    }
                }
                return
            }

            guard (200...299).contains(http.statusCode),
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let sessionId = json["deviceSessionId"] as? String,
                  let proof = json["controlProof"] as? String,
                  let expires = json["expiresAtUtc"] as? String else {
                completion(.failure(PigeonError(code: "server_error", message: "Status \(http.statusCode)", details: nil)))
                return
            }

            completion(.success(IOSDeviceRegisterResponse(
                deviceSessionId: sessionId,
                controlProof: proof,
                expiresAtUtc: expires
            )))
        }.resume()
    }

    func initiateCall(
        tripStopId: String,
        clientRequestId: String,
        completion: @escaping (Result<IOSCallSnapshotResponse, Error>) -> Void
    ) {
        let baseUrl = store.getBaseUrl()
        guard let url = URL(string: "\(baseUrl)/api/v2/voice-calls/initiate") else {
            completion(.failure(PigeonError(code: "invalid_url", message: "Invalid URL", details: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyVoiceHeaders(&request)

        let body: [String: Any] = [
            "tripStopId": tripStopId,
            "clientRequestId": clientRequestId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(PigeonError(code: "network_error", message: "No response", details: nil)))
                return
            }

            if http.statusCode == 401 {
                self?.refreshJwt { success in
                    if success {
                        self?.initiateCall(tripStopId: tripStopId, clientRequestId: clientRequestId, completion: completion)
                    } else {
                        completion(.failure(PigeonError(code: "unauthorized", message: "401 Unauthorized", details: nil)))
                    }
                }
                return
            }

            guard (200...299).contains(http.statusCode),
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let snapshot = self?.parseCallSnapshot(json) else {
                completion(.failure(PigeonError(code: "server_rejected", message: "Status \(http.statusCode)", details: nil)))
                return
            }

            completion(.success(snapshot))
        }.resume()
    }

    func cancelCall(callId: String, completion: @escaping (Bool) -> Void) {
        postSimple(endpoint: "/api/v2/voice-calls/\(callId)/cancel", completion: completion)
    }

    func endCall(callId: String, completion: @escaping (Bool) -> Void) {
        postSimple(endpoint: "/api/v2/voice-calls/\(callId)/end", completion: completion)
    }

    func reportConnecting(callId: String, completion: @escaping (Bool) -> Void) {
        postSimple(endpoint: "/api/v2/voice-calls/\(callId)/reports/connecting", completion: completion)
    }

    func reportConnected(callId: String, completion: @escaping (Bool) -> Void) {
        postSimple(endpoint: "/api/v2/voice-calls/\(callId)/reports/connected", completion: completion)
    }

    func sendHeartbeat(callId: String, completion: @escaping (Bool) -> Void) {
        postSimple(endpoint: "/api/v2/voice-calls/\(callId)/heartbeat", completion: completion)
    }

    func getCallSnapshot(callId: String, completion: @escaping (IOSCallSnapshotResponse?) -> Void) {
        let baseUrl = store.getBaseUrl()
        guard let url = URL(string: "\(baseUrl)/api/v2/voice-calls/\(callId)") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyVoiceHeaders(&request)

        session.dataTask(with: request) { [weak self] data, response, _ in
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let snapshot = self?.parseCallSnapshot(json) else {
                completion(nil)
                return
            }
            completion(snapshot)
        }.resume()
    }

    func getIceServers(callId: String, completion: @escaping ([IOSIceServer]?) -> Void) {
        let baseUrl = store.getBaseUrl()
        guard let url = URL(string: "\(baseUrl)/api/v2/voice-calls/\(callId)/ice-servers") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyVoiceHeaders(&request)

        session.dataTask(with: request) { data, response, _ in
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let arr = json["iceServers"] as? [[String: Any]] else {
                completion(nil)
                return
            }

            var servers: [IOSIceServer] = []
            for item in arr {
                let urls = item["urls"] as? [String] ?? []
                let username = item["username"] as? String
                let credential = item["credential"] as? String
                servers.append(IOSIceServer(urls: urls, username: username, credential: credential))
            }
            completion(servers)
        }.resume()
    }

    private func postSimple(endpoint: String, completion: @escaping (Bool) -> Void) {
        let baseUrl = store.getBaseUrl()
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyVoiceHeaders(&request)

        session.dataTask(with: request) { _, response, _ in
            guard let http = response as? HTTPURLResponse else {
                completion(false)
                return
            }
            completion((200...299).contains(http.statusCode))
        }.resume()
    }

    private func applyVoiceHeaders(_ request: inout URLRequest) {
        if let token = store.getAccessToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let sessionId = store.getDeviceSessionId(), !sessionId.isEmpty {
            request.setValue(sessionId, forHTTPHeaderField: "X-Voice-Device-Session")
        }
        if let proof = store.getControlProof(), !proof.isEmpty {
            request.setValue(proof, forHTTPHeaderField: "X-Voice-Device-Proof")
        }
    }

    private func parseCallSnapshot(_ json: [String: Any]) -> IOSCallSnapshotResponse? {
        guard let callId = json["callId"] as? String,
              let tripStopId = json["tripStopId"] as? String,
              let status = json["status"] as? String else {
            return nil
        }
        let seq = json["sequence"] as? Int ?? 0
        return IOSCallSnapshotResponse(
            callId: callId,
            tripStopId: tripStopId,
            status: status,
            sequence: seq,
            startedAtUtc: json["startedAtUtc"] as? String,
            acceptedAtUtc: json["acceptedAtUtc"] as? String,
            connectedAtUtc: json["connectedAtUtc"] as? String,
            endedAtUtc: json["endedAtUtc"] as? String,
            durationSeconds: json["durationSeconds"] as? Int,
            deadlineAtUtc: json["deadlineAtUtc"] as? String,
            endReason: json["endReason"] as? String
        )
    }
}


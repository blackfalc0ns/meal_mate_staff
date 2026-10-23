import Foundation

protocol VoiceSignalRListener: AnyObject {
    func onBound()
    func onCallEvent(envelope: [String: Any])
    func onOffer(callId: String, sdp: String, messageId: String, generation: Int)
    func onAnswer(callId: String, sdp: String, messageId: String, generation: Int)
    func onIceCandidate(callId: String, candidate: String, sdpMid: String?, sdpMLineIndex: Int?, usernameFragment: String?, messageId: String, generation: Int)
    func onConnectionStateChanged(connected: Bool)
}

final class VoiceSignalRClient: NSObject, URLSessionWebSocketDelegate, VoiceMediaSignaling {
    private let store: VoiceCallStore
    private let apiClient: VoiceAPIClient?
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var isConnected = false
    private var isConnecting = false
    private var isBound = false
    private var boundSessionId: String?
    private var bindingSessionId: String?
    private var invocationCounter = 1
    private var epoch = 0
    private var explicitlyDisconnected = false
    private var reconnectWork: DispatchWorkItem?
    private var bindingWaiters: [UUID: (Bool) -> Void] = [:]
    private let separator = "\u{1E}"
    weak var listener: VoiceSignalRListener?

    init(store: VoiceCallStore, apiClient: VoiceAPIClient? = nil) {
        self.store = store
        self.apiClient = apiClient
        super.init()
    }
    private func onMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread { action() } else { DispatchQueue.main.async(execute: action) }
    }
    func connectWhenBound(timeout: TimeInterval = 15, completion: @escaping (Bool) -> Void) {
        onMain { [weak self] in
            guard let self = self else { completion(false); return }
            if self.isBound && self.boundSessionId == self.store.getDeviceSessionId() { completion(true); return }
            let id = UUID()
            self.bindingWaiters[id] = completion
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
                self?.bindingWaiters.removeValue(forKey: id)?(false)
            }
            if self.isConnected { self.bindCurrentSession() } else { self.connect() }
        }
    }
    func connect() {
        onMain { [weak self] in
            guard let self = self, !self.isConnected, !self.isConnecting else { return }
            guard let token = self.store.getAccessToken(), !token.isEmpty, !self.store.getHubUrl().isEmpty else {
                self.finishWaiters(false)
                return
            }
            self.explicitlyDisconnected = false
            self.isConnecting = true
            self.epoch += 1
            let attempt = self.epoch
            let hub = self.store.getHubUrl().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            self.negotiate(hub: hub, token: token) { [weak self] result in
                self?.onMain {
                    guard let self = self, self.epoch == attempt, !self.explicitlyDisconnected else { return }
                    switch result {
                    case .success(let credentials): self.openSocket(hub: credentials.hub, token: credentials.token, connectionToken: credentials.connectionToken)
                    case .failure:
                        self.isConnecting = false
                        self.scheduleReconnect()
                    }
                }
            }
        }
    }
    private struct Credentials { let hub: String; let token: String; let connectionToken: String? }
    private func negotiate(hub: String, token: String, retry: Bool = false, completion: @escaping (Result<Credentials, Error>) -> Void) {
        guard let url = URL(string: "\(hub)/negotiate?negotiateVersion=1") else { completion(.failure(URLError(.badURL))); return }
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error { completion(.failure(error)); return }
            if (response as? HTTPURLResponse)?.statusCode == 401, !retry, let self = self, let api = self.apiClient {
                api.refreshJwt { ready in
                    if ready, let token = self.store.getAccessToken() { self.negotiate(hub: hub, token: token, retry: true, completion: completion) }
                    else { completion(.failure(URLError(.userAuthenticationRequired))) }
                }
                return
            }
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode), let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(URLError(.badServerResponse))); return
            }
            completion(.success(Credentials(hub: json["url"] as? String ?? hub, token: json["accessToken"] as? String ?? token,
                                            connectionToken: json["connectionToken"] as? String ?? json["connectionId"] as? String)))
        }.resume()
    }
    private func openSocket(hub: String, token: String, connectionToken: String?) {
        guard var url = URLComponents(string: hub) else { isConnecting = false; finishWaiters(false); return }
        if url.scheme == "https" { url.scheme = "wss" }
        if url.scheme == "http" { url.scheme = "ws" }
        var query = url.queryItems ?? []
        if let id = connectionToken { query.append(URLQueryItem(name: "id", value: id)) }
        query.append(URLQueryItem(name: "access_token", value: token))
        url.queryItems = query
        guard let endpoint = url.url else { isConnecting = false; finishWaiters(false); return }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        self.session = session
        var request = URLRequest(url: endpoint)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = session.webSocketTask(with: request)
        webSocketTask = task
        task.resume()
        task.send(.string("{\"protocol\":\"json\",\"version\":1}\(separator)")) { [weak self, weak task] error in
            if error != nil, let task = task { self?.onMain { self?.lostConnection(task) } }
        }
        receive(task)
    }
    private func receive(_ task: URLSessionWebSocketTask) {
        task.receive { [weak self, weak task] result in
            guard let self = self, let task = task else { return }
            self.onMain {
                guard task === self.webSocketTask else { return }
                switch result {
                case .failure: self.lostConnection(task)
                case .success(let message):
                    switch message {
                    case .string(let text): self.handleText(text)
                    case .data(let data): if let text = String(data: data, encoding: .utf8) { self.handleText(text) }
                    @unknown default: break
                    }
                    if task === self.webSocketTask { self.receive(task) }
                }
            }
        }
    }
    private func lostConnection(_ task: URLSessionWebSocketTask) {
        guard task === webSocketTask else { return }
        webSocketTask = nil
        task.cancel(with: .goingAway, reason: nil)
        session?.invalidateAndCancel()
        session = nil
        isConnected = false
        isConnecting = false
        isBound = false
        boundSessionId = nil
        bindingSessionId = nil
        listener?.onConnectionStateChanged(connected: false)
        scheduleReconnect()
    }
    private func scheduleReconnect() {
        guard !explicitlyDisconnected, reconnectWork == nil else { return }
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.reconnectWork = nil
            if !self.explicitlyDisconnected { self.connect() }
        }
        reconnectWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }
    private func finishWaiters(_ ready: Bool) {
        let waiters = Array(bindingWaiters.values)
        bindingWaiters.removeAll()
        waiters.forEach { $0(ready) }
    }
    private func bindCurrentSession() {
        guard let id = store.getDeviceSessionId(), !id.isEmpty, let proof = store.getControlProof(), !proof.isEmpty else { finishWaiters(false); return }
        guard bindingSessionId != id else { return }
        isBound = false
        boundSessionId = nil
        bindingSessionId = id
        sendInvocation(target: "BindDeviceSession", args: [id, proof])
    }
    private func handleText(_ text: String) {
        for part in text.components(separatedBy: separator) where !part.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            guard let data = part.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
            if json.isEmpty {
                isConnected = true
                isConnecting = false
                listener?.onConnectionStateChanged(connected: true)
                bindCurrentSession()
                continue
            }
            if json["type"] as? Int == 6 { sendRaw("{\"type\":6}\(separator)"); continue }
            if json["type"] as? Int == 7, let task = webSocketTask { lostConnection(task); continue }
            if json["type"] as? Int == 1, let target = json["target"] as? String { dispatchInvocation(target, json["arguments"] as? [Any] ?? []) }
        }
    }
    private func dispatchInvocation(_ target: String, _ args: [Any]) {
        if target == "bound" {
            boundSessionId = bindingSessionId
            bindingSessionId = nil
            isBound = boundSessionId == store.getDeviceSessionId()
            if isBound { finishWaiters(true); listener?.onBound() } else { bindCurrentSession() }
            return
        }
        if ["call:event", "OnCallEvent", "CallEvent"].contains(target) {
            if let envelope = args.first as? [String: Any] { listener?.onCallEvent(envelope: envelope) }
            return
        }
        guard let rtc = decode(args) else { return }
        if ["rtc:offer", "OnOffer", "Offer"].contains(target), let sdp = rtc.payload["sdp"] as? String {
            listener?.onOffer(callId: rtc.callId, sdp: sdp, messageId: rtc.messageId, generation: rtc.generation)
        } else if ["rtc:answer", "OnAnswer", "Answer"].contains(target), let sdp = rtc.payload["sdp"] as? String {
            listener?.onAnswer(callId: rtc.callId, sdp: sdp, messageId: rtc.messageId, generation: rtc.generation)
        } else if ["rtc:ice-candidate", "OnIceCandidate", "IceCandidate", "rtc:ice"].contains(target), let candidate = rtc.payload["candidate"] as? String {
            listener?.onIceCandidate(callId: rtc.callId, candidate: candidate, sdpMid: rtc.payload["sdpMid"] as? String,
                                    sdpMLineIndex: rtc.payload["sdpMLineIndex"] as? Int, usernameFragment: rtc.payload["usernameFragment"] as? String,
                                    messageId: rtc.messageId, generation: rtc.generation)
        }
    }
    private typealias RTCEnvelope = (callId: String, messageId: String, generation: Int, payload: [String: Any])
    private func decode(_ args: [Any]) -> RTCEnvelope? {
        if args.count >= 4 { return (args[0] as? String ?? "", args[2] as? String ?? "", args[3] as? Int ?? 0, args[1] as? [String: Any] ?? [:]) }
        if let env = args.first as? [String: Any] {
            return (env["callId"] as? String ?? "", env["messageId"] as? String ?? "", env["negotiationGeneration"] as? Int ?? env["generation"] as? Int ?? 0, env["payload"] as? [String: Any] ?? [:])
        }
        return nil
    }
    @discardableResult func sendOffer(callId: String, sdp: String, messageId: String, generation: Int) -> Bool {
        sendInvocation(target: "SendOffer", args: [callId, ["type": "offer", "sdp": sdp], messageId, generation])
    }
    func sendAnswer(callId: String, sdp: String, messageId: String, generation: Int) {
        sendInvocation(target: "SendAnswer", args: [callId, ["type": "answer", "sdp": sdp], messageId, generation])
    }
    func sendIceCandidate(callId: String, candidate: String, sdpMid: String?, sdpMLineIndex: Int?, usernameFragment: String?, messageId: String, generation: Int) {
        var payload: [String: Any] = ["candidate": candidate]
        if let mid = sdpMid { payload["sdpMid"] = mid }
        if let index = sdpMLineIndex { payload["sdpMLineIndex"] = index }
        if let fragment = usernameFragment { payload["usernameFragment"] = fragment }
        sendInvocation(target: "SendIceCandidate", args: [callId, payload, messageId, generation])
    }
    @discardableResult private func sendInvocation(target: String, args: [Any]) -> Bool {
        guard isConnected, target == "BindDeviceSession" || isBound else { return false }
        let message: [String: Any] = ["type": 1, "invocationId": String(invocationCounter), "target": target, "arguments": args]
        invocationCounter += 1
        guard let data = try? JSONSerialization.data(withJSONObject: message), let text = String(data: data, encoding: .utf8) else { return false }
        return sendRaw(text + separator)
    }
    @discardableResult private func sendRaw(_ text: String) -> Bool {
        guard let task = webSocketTask else { return false }
        task.send(.string(text)) { [weak self, weak task] error in
            if error != nil, let task = task { self?.onMain { self?.lostConnection(task) } }
        }
        return true
    }
    func disconnect() {
        onMain { [weak self] in
            guard let self = self else { return }
            self.explicitlyDisconnected = true
            self.epoch += 1
            self.reconnectWork?.cancel()
            self.reconnectWork = nil
            let task = self.webSocketTask
            self.webSocketTask = nil
            task?.cancel(with: .normalClosure, reason: nil)
            self.session?.invalidateAndCancel()
            self.session = nil
            self.isConnected = false
            self.isConnecting = false
            self.isBound = false
            self.boundSessionId = nil
            self.bindingSessionId = nil
            self.finishWaiters(false)
        }
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        onMain { [weak self] in self?.lostConnection(webSocketTask) }
    }
}


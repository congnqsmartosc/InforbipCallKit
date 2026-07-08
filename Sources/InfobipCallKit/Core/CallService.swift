import Foundation
import InfobipRTC
import PushKit

enum CallServiceError: LocalizedError {
    case notRegistered

    var errorDescription: String? {
        switch self {
        case .notRegistered:
            return "No subscriber registered. Call registerSubscriber(identity:displayName:token:) first."
        }
    }
}

/// The logged-in subscriber. The `token` is supplied by the host app (typically obtained from
/// its backend calling Infobip `POST /webrtc/1/token`) — the framework never mints tokens.
struct Subscriber {
    let identity: String
    let displayName: String
    var token: String
}

/// The single facade that talks to the InfobipRTC SDK.
/// The Coordinator/ViewModels use only this protocol + `ActiveCall`; they never import InfobipRTC.
protocol CallServiceType: AnyObject {
    var subscriber: Subscriber? { get }
    var onIncomingCall: ((ActiveCall) -> Void)? { get set }

    /// Store the logged-in subscriber (identity + display name + host-provided token).
    func registerSubscriber(identity: String, displayName: String, token: String)

    /// Replace the cached token (e.g. after refresh).
    func updateToken(_ token: String)

    /// Clear subscriber state (e.g. on logout) and tear down the incoming-call channel.
    func clearSubscriber()

    /// Open the channel that receives incoming calls for the registered subscriber.
    func registerForIncomingCalls() throws

    /// Feed a push payload to the SDK. Returns true when handled as an Infobip incoming call.
    func handlePushNotification(_ payload: [String: String]) -> Bool

    /// Place a WebRTC call to `destinationIdentity`. `customData` is forwarded to the callee.
    /// Returns an `ActiveCall` with its listener already attached.
    func makeCall(destinationIdentity: String, customData: [String: String]) async throws -> ActiveCall
}

final class CallService: NSObject, CallServiceType {

    private let config: InfobipCallConfig
    private var pushRegistry: PKPushRegistry?

    /// Push payloads keyed by callId — to retry handleIncomingCall when the SDK can't fetch the
    /// call within 3s ("Call did not arrive in 3 seconds") on the first call after app launch.
    private var pendingPayloads: [String: PKPushPayload] = [:]
    private var retriedCallIds: Set<String> = []

    private(set) var subscriber: Subscriber?
    var onIncomingCall: ((ActiveCall) -> Void)?

    private var infobipRTC: InfobipRTC { getInfobipRTCInstance() }

    init(config: InfobipCallConfig) {
        self.config = config
        super.init()
    }

    // MARK: - Subscriber

    func registerSubscriber(identity: String, displayName: String, token: String) {
        subscriber = Subscriber(identity: identity, displayName: displayName, token: token)
        log("registered subscriber \(identity)")
    }

    func updateToken(_ token: String) {
        subscriber?.token = token
    }

    func clearSubscriber() {
        pushRegistry?.delegate = nil
        pushRegistry = nil
        subscriber = nil
        log("cleared subscriber")
    }

    // MARK: - Incoming registration

    func registerForIncomingCalls() throws {
        guard let subscriber = subscriber else { throw CallServiceError.notRegistered }

        // The SDK receives incoming calls over PushKit. When no APNs VoIP is configured
        // (pushConfigId == nil) it uses InfobipSimulator: an active connection to Infobip that
        // delivers calls while the app is foregrounded. Tear down any prior registry first so
        // switching subscriber doesn't keep two live connections.
        pushRegistry?.delegate = nil
        pushRegistry = nil

        let registry: PKPushRegistry
        if config.pushConfigId != nil {
            registry = PKPushRegistry(queue: .main)
        } else {
            registry = InfobipSimulator(token: subscriber.token)
        }
        registry.desiredPushTypes = [.voIP]
        registry.delegate = self
        pushRegistry = registry
        log("listening for incoming calls, registry: \(type(of: registry))")
    }

    func handlePushNotification(_ payload: [String: String]) -> Bool {
        // Present for cross-platform (Android) API parity. On iOS, VoIP pushes are delivered as
        // `PKPushPayload` objects through PushKit, which cannot be reconstructed from a plain
        // dictionary — incoming calls are handled by the internal PKPushRegistry / InfobipSimulator
        // (see `registerForIncomingCalls()`). Hosts wiring their own real APNs VoIP path should
        // forward the raw `PKPushPayload` to the SDK from their `PKPushRegistryDelegate` instead.
        return false
    }

    // MARK: - Outgoing

    func makeCall(destinationIdentity: String, customData: [String: String]) async throws -> ActiveCall {
        guard let subscriber = subscriber else { throw CallServiceError.notRegistered }

        // The caller's own screen resolves the callee from the WebRTC endpoint (displayIdentifier
        // → identity), so no local customData is needed here. The passed `customData` is forwarded
        // to the callee so their incoming screen can show this caller's name/avatar.
        let activeCall = ActiveCall(outgoingCustomData: [:], customDataKeys: config.customDataKeys)

        let request = CallWebrtcRequest(
            subscriber.token,
            destination: destinationIdentity,
            webrtcCallEventListener: activeCall
        )
        let options = WebrtcCallOptions(customData: customData)

        let call = try await MainActor.run {
            try infobipRTC.callWebrtc(request, options)
        }
        activeCall.attach(call)
        return activeCall
    }

    private func log(_ message: String) {
        print("[InfobipCallKit][CallService] \(message)")
    }
}

// MARK: - PKPushRegistryDelegate + IncomingCallEventListener

extension CallService: PKPushRegistryDelegate, IncomingCallEventListener {

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        log("didUpdate pushCredentials type=\(type.rawValue)")
        guard type == .voIP, let configId = config.pushConfigId, let subscriber = subscriber else { return }
        #if DEBUG
        let debug = true
        #else
        let debug = false
        #endif
        infobipRTC.enablePushNotification(subscriber.token, pushCredentials: pushCredentials, debug: debug, pushConfigId: configId)
    }

    // InfobipRTC (including InfobipSimulator) ONLY calls the completion-handler variant
    // (selector ...withCompletionHandler: in the binary SDK) — this variant MUST be implemented,
    // otherwise incoming calls are dropped silently and the caller gets NO_ANSWER.
    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        handleIncomingPush(payload, type: type)
        completion()
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        handleIncomingPush(payload, type: type)
    }

    private func handleIncomingPush(_ payload: PKPushPayload, type: PKPushType) {
        log("didReceiveIncomingPush type=\(type.rawValue) payload=\(payload.dictionaryPayload)")
        guard type == .voIP else { return }
        guard infobipRTC.isIncomingCall(payload) else {
            log("payload is NOT an incoming webrtc call — ignored")
            return
        }
        if let callId = payload.dictionaryPayload["callId"] as? String {
            pendingPayloads[callId] = payload
        }
        infobipRTC.handleIncomingCall(payload, self)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let subscriber = subscriber else { return }
        infobipRTC.disablePushNotification(subscriber.token)
    }

    func onIncomingWebrtcCall(_ incomingWebrtcCallEvent: IncomingWebrtcCallEvent) {
        log("onIncomingWebrtcCall from \(incomingWebrtcCallEvent.incomingWebrtcCall.source().identifier())")
        let activeCall = ActiveCall(
            incomingCall: incomingWebrtcCallEvent.incomingWebrtcCall,
            customData: incomingWebrtcCallEvent.customData,
            customDataKeys: config.customDataKeys
        )
        watchForEarlyDeath(of: activeCall)
        DispatchQueue.main.async { [weak self] in
            self?.onIncomingCall?(activeCall)
        }
    }

    /// The first incoming call after app launch can die with "Call did not arrive in 3 seconds"
    /// (cold socket to the platform). The caller is still ringing → retry once with the same
    /// payload; the connection is warm now so it usually succeeds.
    private func watchForEarlyDeath(of activeCall: ActiveCall) {
        activeCall.observe { [weak self, weak activeCall] event in
            guard case .hangup = event,
                  let self = self,
                  let activeCall = activeCall,
                  !activeCall.didUserRespond,
                  !activeCall.isEstablished else { return }

            let callId = activeCall.callId
            guard let payload = self.pendingPayloads[callId],
                  !self.retriedCallIds.contains(callId) else { return }

            self.retriedCallIds.insert(callId)
            self.log("incoming call \(callId) died before user response — retrying handleIncomingCall")
            self.infobipRTC.handleIncomingCall(payload, self)
        }
    }
}

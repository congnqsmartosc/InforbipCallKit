import Foundation
import InfobipRTC
import PushKit
import CallKit

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
    /// The subscriber's own avatar, auto-forwarded to callees via `customData` on outgoing calls.
    var imageURL: String?
}

/// The single facade that talks to the InfobipRTC SDK.
/// The Coordinator/ViewModels use only this protocol + `ActiveCall`; they never import InfobipRTC.
protocol CallServiceType: AnyObject {
    var subscriber: Subscriber? { get }
    var onIncomingCall: ((ActiveCall) -> Void)? { get set }
    /// Fires when an incoming call is answered on the CallKit system UI — the client presents the
    /// in-call screen for `call` (which is already accepting/established; do NOT call accept again).
    var onCallAnswered: ((ActiveCall) -> Void)? { get set }

    /// `true` when CallKit is enabled by config (`config.isCallKitEnabled`).
    var isCallKitEnabled: Bool { get }

    /// Create and register the CallKit provider (`CXProvider`). Call when the app actually starts
    /// using Infobip. No-op when CallKit isn't enabled by config, or when already active.
    func activateCallService()

    /// Tear down the CallKit provider so another SDK (e.g. a GSM call SDK) can own CallKit, or on
    /// logout. Ends any in-flight calls. Safe to call when already inactive.
    func deactivateCallService()

    /// Store the logged-in subscriber (identity + display name + host-provided token + avatar).
    func registerSubscriber(identity: String, displayName: String, token: String, imageURL: String?)

    /// Replace the cached token (e.g. after refresh).
    func updateToken(_ token: String)

    /// Clear subscriber state (e.g. on logout) and tear down the incoming-call channel.
    func clearSubscriber()

    /// Open the InfobipSimulator channel (foreground dev path only). No-op on the CallKit/APNs
    /// path, where the host owns the `PKPushRegistry` and drives push via ``enablePush(credentials:)``.
    func registerForIncomingCalls() throws

    /// CallKit/APNs path: bind the host's VoIP `PKPushCredentials` to Infobip (host calls this from
    /// its own `PKPushRegistryDelegate.pushRegistry(_:didUpdate:for:)`).
    func enablePush(credentials: PKPushCredentials)

    /// CallKit/APNs path: unbind push from Infobip (host calls this from
    /// `pushRegistry(_:didInvalidatePushTokenFor:)`, or on logout).
    func disablePush()

    /// CallKit/APNs path: hand a VoIP `PKPushPayload` the host received off to Infobip. MUST be
    /// called synchronously from the host's `didReceiveIncomingPushWith` before `completion()`, so
    /// the incoming call is reported to CallKit before iOS can kill a push-launched app.
    /// Returns true when the payload was an Infobip incoming call.
    @discardableResult
    func handleIncomingPush(_ payload: PKPushPayload) -> Bool

    /// Feed a push payload to the SDK. Returns true when handled as an Infobip incoming call.
    func handlePushNotification(_ payload: [String: String]) -> Bool

    /// Place a WebRTC call to `destinationIdentity`. `customData` is forwarded to the callee.
    /// Returns an `ActiveCall` with its listener already attached.
    func makeCall(destinationIdentity: String, customData: [String: String]) async throws -> ActiveCall
}

/// Tracks an incoming call reported to CallKit whose `ActiveCall` may not have arrived yet.
final class PendingIncoming {
    let uuid: UUID
    let callId: String
    var activeCall: ActiveCall?
    var answerAction: CXAnswerCallAction?
    var answered = false
    var declineRequested = false

    init(uuid: UUID, callId: String) {
        self.uuid = uuid
        self.callId = callId
    }
}

final class CallService: NSObject, CallServiceType {

    private let config: InfobipCallConfig
    private var pushRegistry: PKPushRegistry?
    /// The CallKit provider wrapper. Created lazily by ``activateCallService()`` and released by
    /// ``deactivateCallService()`` — `nil` means CallKit is not currently owned by the pod.
    private var callKit: CallKitManager?

    var isCallKitEnabled: Bool { config.isCallKitEnabled }

    /// `true` once ``activateCallService()`` has created the CallKit provider.
    private var isCallKitActive: Bool { callKit != nil }

    /// Push payloads keyed by callId — to retry handleIncomingCall when the SDK can't fetch the
    /// call within 3s ("Call did not arrive in 3 seconds") on the first call after app launch.
    private var pendingPayloads: [String: PKPushPayload] = [:]
    private var retriedCallIds: Set<String> = []

    // CallKit state
    private var incomingByCallId: [String: PendingIncoming] = [:]
    private var outgoing: (uuid: UUID, call: ActiveCall)?
    private var pendingPushCredentials: PKPushCredentials?

    private(set) var subscriber: Subscriber?
    var onIncomingCall: ((ActiveCall) -> Void)?
    var onCallAnswered: ((ActiveCall) -> Void)?

    private var infobipRTC: InfobipRTC { getInfobipRTCInstance() }

    init(config: InfobipCallConfig) {
        self.config = config
        super.init()
        // CallKit (CXProvider) is NOT created here — the host calls activateCallService() when it
        // actually starts using Infobip. This lets the center + host PushKit init early while
        // leaving CallKit free for another SDK until Infobip is chosen.
    }

    // MARK: - CallKit lifecycle

    func activateCallService() {
        guard config.isCallKitEnabled else {
            log("activateCallService ignored — CallKit disabled (pushConfigId nil / enableCallKit false)")
            return
        }
        guard callKit == nil else { return }
        callKit = CallKitManager(config: config)
        wireCallKit()
        log("CallKit activated")
    }

    func deactivateCallService() {
        guard callKit != nil else { return }
        // End any in-flight calls and clear CallKit-tracked state before releasing the provider.
        incomingByCallId.values.forEach { $0.activeCall?.hangup() }
        incomingByCallId.removeAll()
        outgoing?.call.hangup()
        outgoing = nil
        callKit?.invalidate()
        callKit = nil
        log("CallKit deactivated")
    }

    // MARK: - Subscriber

    func registerSubscriber(identity: String, displayName: String, token: String, imageURL: String?) {
        subscriber = Subscriber(identity: identity, displayName: displayName, token: token, imageURL: imageURL)
        log("registered subscriber \(identity) displayName=\(displayName) hasImage=\(imageURL != nil)")
        // If a VoIP token already arrived before the subscriber was known, bind push now.
        enablePushIfPossible()
    }

    func updateToken(_ token: String) {
        subscriber?.token = token
        log("token updated")
        enablePushIfPossible()
    }

    func clearSubscriber() {
        if let token = subscriber?.token, config.pushConfigId != nil {
            infobipRTC.disablePushNotification(token)
        }
        pushRegistry?.delegate = nil
        pushRegistry = nil
        pendingPushCredentials = nil
        subscriber = nil
        log("cleared subscriber")
    }

    // MARK: - Incoming registration

    func registerForIncomingCalls() throws {
        // CallKit/APNs path: the HOST owns the PKPushRegistry and drives push via
        // enablePush(credentials:) + handleIncomingPush(_:). Nothing to start in the pod.
        guard !isCallKitEnabled else {
            enablePushIfPossible()
            return
        }

        guard let subscriber = subscriber else { throw CallServiceError.notRegistered }

        // Foreground dev path: InfobipSimulator is an active connection to Infobip that delivers
        // calls while the app is foregrounded. Tear down any prior registry first.
        pushRegistry?.delegate = nil
        pushRegistry = nil

        let registry = InfobipSimulator(token: subscriber.token)
        registry.desiredPushTypes = [.voIP]
        registry.delegate = self
        pushRegistry = registry
        log("listening for incoming calls, registry: \(type(of: registry))")
    }

    // MARK: - Host-driven push (CallKit / APNs path)

    func enablePush(credentials: PKPushCredentials) {
        log("host provided VoIP push credentials")
        pendingPushCredentials = credentials
        enablePushIfPossible()
    }

    func disablePush() {
        if let token = subscriber?.token, config.pushConfigId != nil {
            infobipRTC.disablePushNotification(token)
        }
        pendingPushCredentials = nil
        log("disabled VoIP push")
    }

    func handleIncomingPush(_ payload: PKPushPayload) -> Bool {
        return handleIncomingPush(payload, type: .voIP)
    }

    func handlePushNotification(_ payload: [String: String]) -> Bool {
        // Present for cross-platform (Android) API parity. On iOS, VoIP pushes are delivered as
        // `PKPushPayload` objects through the pod's own PKPushRegistry — not a plain dictionary.
        return false
    }

    // MARK: - Push binding

    private func enablePushIfPossible() {
        guard config.pushConfigId != nil,
              let subscriber = subscriber,
              let credentials = pendingPushCredentials else { return }
        enablePush(token: subscriber.token, credentials: credentials)
    }

    private func enablePush(token: String, credentials: PKPushCredentials) {
        guard let configId = config.pushConfigId else { return }
        #if DEBUG
        let debug = true
        #else
        let debug = false
        #endif
        infobipRTC.enablePushNotification(token, pushCredentials: credentials, debug: debug, pushConfigId: configId) { [weak self] result in
            self?.log("enablePushNotification status=\(result.status == .success ? "success" : "failure") message=\(result.message)")
        }
    }

    // MARK: - Outgoing

    func makeCall(destinationIdentity: String, customData: [String: String]) async throws -> ActiveCall {
        guard let subscriber = subscriber else { throw CallServiceError.notRegistered }

        let activeCall = ActiveCall(outgoingCustomData: [:], customDataKeys: config.customDataKeys)

        // Auto-forward the registered subscriber's own display info to the callee, so the host
        // doesn't have to build customData by hand. Any keys the host passed explicitly win.
        var forwarded: [String: String] = [:]
        forwarded[config.customDataKeys.displayName] = subscriber.displayName
        if let imageURL = subscriber.imageURL {
            forwarded[config.customDataKeys.avatarURL] = imageURL
        }
        forwarded.merge(customData) { _, hostValue in hostValue }

        log("makeCall → \(destinationIdentity) customData keys=\(forwarded.keys.sorted())")

        let request = CallWebrtcRequest(
            subscriber.token,
            destination: destinationIdentity,
            webrtcCallEventListener: activeCall
        )
        let options = WebrtcCallOptions(customData: forwarded)

        let call = try await MainActor.run {
            try infobipRTC.callWebrtc(request, options)
        }
        activeCall.attach(call)

        if isCallKitActive {
            let uuid = UUID(uuidString: activeCall.callId) ?? UUID()
            outgoing = (uuid, activeCall)
            callKit?.startOutgoingCall(uuid: uuid, handle: destinationIdentity)
            observeOutgoingForCallKit(activeCall, uuid: uuid)
        }
        return activeCall
    }

    private func observeOutgoingForCallKit(_ call: ActiveCall, uuid: UUID) {
        call.observe { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .ringing, .earlyMedia:
                self.callKit?.reportOutgoingConnecting(uuid: uuid)
            case .established:
                self.callKit?.reportOutgoingConnected(uuid: uuid)
            case .hangup(let reason), .error(let reason):
                self.callKit?.reportCallEnded(uuid: uuid, reason: reason.isError ? .failed : .remoteEnded)
                if self.outgoing?.uuid == uuid { self.outgoing = nil }
            default:
                break
            }
        }
    }

    // MARK: - CallKit action wiring

    private func wireCallKit() {
        guard let callKit = callKit else { return }

        callKit.onAnswer = { [weak self] uuid, action in
            self?.handleCallKitAnswer(uuid: uuid, action: action)
        }
        callKit.onEnd = { [weak self] uuid, action in
            self?.handleCallKitEnd(uuid: uuid)
            action.fulfill()
        }
        callKit.onMute = { [weak self] uuid, muted, action in
            self?.callForUUID(uuid)?.setMuted(muted)
            action.fulfill()
        }
        callKit.onStartCall = { _, action in
            action.fulfill()   // the SDK call is already being placed by makeCall.
        }
        callKit.onReset = { [weak self] in
            guard let self = self else { return }
            self.incomingByCallId.values.forEach { $0.activeCall?.hangup() }
            self.outgoing?.call.hangup()
        }
    }

    private func handleCallKitAnswer(uuid: UUID, action: CXAnswerCallAction) {
        guard let pending = pendingForUUID(uuid) else { action.fail(); return }
        pending.answered = true
        if let call = pending.activeCall {
            call.accept()
            action.fulfill()
            onCallAnswered?(call)
        } else {
            // The SDK hasn't delivered the call yet — queue the answer and add a safety timeout.
            pending.answerAction = action
            let callId = pending.callId
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self, weak pending] in
                guard let pending = pending, pending.activeCall == nil, pending.answerAction != nil else { return }
                self?.log("answer timed out for callId=\(callId) — failing action")
                pending.answerAction?.fail()
                pending.answerAction = nil
                self?.callKit?.reportCallEnded(uuid: uuid, reason: .failed)
                self?.incomingByCallId[callId] = nil
            }
        }
    }

    private func handleCallKitEnd(uuid: UUID) {
        if let pending = pendingForUUID(uuid) {
            if let call = pending.activeCall {
                if call.isEstablished { call.hangup() } else { call.decline() }
            } else {
                pending.declineRequested = true
            }
            incomingByCallId[pending.callId] = nil
            return
        }
        if let outgoing = outgoing, outgoing.uuid == uuid {
            outgoing.call.hangup()
            self.outgoing = nil
        }
    }

    private func pendingForUUID(_ uuid: UUID) -> PendingIncoming? {
        incomingByCallId.values.first { $0.uuid == uuid }
    }

    private func callForUUID(_ uuid: UUID) -> ActiveCall? {
        if let outgoing = outgoing, outgoing.uuid == uuid { return outgoing.call }
        return pendingForUUID(uuid)?.activeCall
    }

    private func log(_ message: String) {
        CallLog.debug(message, category: "CallService")
    }
}

// MARK: - PKPushRegistryDelegate + IncomingCallEventListener

// NOTE: On the CallKit/APNs path the HOST owns the PKPushRegistry and its delegate — the pod is
// driven through enablePush(credentials:) / handleIncomingPush(_:) / disablePush() instead. These
// PKPushRegistryDelegate methods are only invoked by the pod-owned `InfobipSimulator` (foreground
// dev path), which mimics a registry over an active Infobip connection.
extension CallService: PKPushRegistryDelegate, IncomingCallEventListener {

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        log("didUpdate pushCredentials type=\(type.rawValue)")
        guard type == .voIP else { return }
        pendingPushCredentials = pushCredentials
        enablePushIfPossible()
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

    @discardableResult
    private func handleIncomingPush(_ payload: PKPushPayload, type: PKPushType) -> Bool {
        log("didReceiveIncomingPush type=\(type.rawValue) payload=\(payload.dictionaryPayload)")
        guard type == .voIP else { return false }

        guard infobipRTC.isIncomingCall(payload) else {
            log("payload is NOT an incoming webrtc call — ignored")
            // On the CallKit path iOS requires a report for every VoIP push; report then end it.
            if isCallKitActive {
                let uuid = UUID()
                callKit?.reportIncomingCall(uuid: uuid, callerName: config.callKitDisplayName) { [weak self] _ in
                    self?.callKit?.reportCallEnded(uuid: uuid, reason: .failed)
                }
            }
            return false
        }

        let callId = (payload.dictionaryPayload["callId"] as? String) ?? UUID().uuidString
        pendingPayloads[callId] = payload

        if isCallKitActive {
            // MUST report synchronously before completion() or iOS kills a push-launched app.
            let uuid = UUID(uuidString: callId) ?? UUID()
            let pending = PendingIncoming(uuid: uuid, callId: callId)
            incomingByCallId[callId] = pending
            let callerName = (payload.dictionaryPayload["callerName"] as? String) ?? config.callKitDisplayName
            callKit?.reportIncomingCall(uuid: uuid, callerName: callerName)
        }

        infobipRTC.handleIncomingCall(payload, self)
        return true
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
            guard let self = self else { return }
            if self.isCallKitActive {
                self.attachToPending(activeCall)
            }
            // Bind the session for host observers (banner presentation is suppressed on the CallKit
            // path inside the client — it only presents once the call is answered).
            self.onIncomingCall?(activeCall)
        }
    }

    /// Correlate a freshly-delivered `ActiveCall` with the CallKit call reported at push time, and
    /// resolve any answer/decline the user already made on the system UI.
    private func attachToPending(_ activeCall: ActiveCall) {
        let pending = incomingByCallId[activeCall.callId] ?? incomingByCallId.values.first(where: { $0.activeCall == nil })
        guard let pending = pending else { return }
        pending.activeCall = activeCall

        callKit?.updateCaller(uuid: pending.uuid, name: activeCall.counterpartName)

        // Report remote-initiated ends to CallKit so the system UI dismisses.
        activeCall.observe { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .hangup(let reason), .error(let reason):
                self.callKit?.reportCallEnded(uuid: pending.uuid, reason: reason.isError ? .failed : .remoteEnded)
                self.incomingByCallId[pending.callId] = nil
            default:
                break
            }
        }

        if pending.declineRequested {
            activeCall.decline()
            incomingByCallId[pending.callId] = nil
        } else if pending.answered {
            activeCall.accept()
            pending.answerAction?.fulfill()
            pending.answerAction = nil
            onCallAnswered?(activeCall)
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

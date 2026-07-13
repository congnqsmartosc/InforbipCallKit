import Foundation
import AVFoundation
import PushKit

/// Concrete ``InfobipCallClient`` — bridges the SDK facade (`CallService` / `ActiveCall`) to the
/// public value-typed `CallSession` state, and fans that state out to the delegate, closure
/// observers, and (optionally) the RxSwift extension.
final class InfobipCallClientImpl: InfobipCallClient {

    // MARK: State fan-out

    private(set) var activeSession: CallSession? {
        didSet { notify() }
    }
    weak var delegate: InfobipCallClientDelegate?
    private var observers: [UUID: (CallSession?) -> Void] = [:]
    private var eventObservers: [UUID: (InfobipCallEvent) -> Void] = [:]

    /// Latest quality observed for the current call, carried across `CallSession` rebuilds.
    private var currentNetworkQuality: InfobipNetworkQuality?

    /// How the center should present the built-in UI for a call.
    enum Presentation {
        case incomingBanner     // custom banner (foreground dev / non-CallKit path)
        case incomingAnswered   // in-call screen for a call already answered via CallKit
        case outgoing           // outgoing in-call screen
    }

    /// Internal hook the center uses to present the built-in UI when a call starts.
    var onPresentCall: ((_ call: ActiveCall, _ presentation: Presentation) -> Void)?

    // MARK: Dependencies / call state

    private let service: CallServiceType
    private let config: InfobipCallConfig

    /// Retained live call backing the current `activeSession` (for accept/hangup/mute/etc).
    private var currentCall: ActiveCall?
    private var currentObserverId: UUID?

    /// Last outgoing target, for "Try again" on the unreachable screen.
    private var lastOutgoing: (identity: String, customData: [String: String])?

    init(service: CallServiceType, config: InfobipCallConfig) {
        self.service = service
        self.config = config
        self.service.onIncomingCall = { [weak self] call in
            self?.handleIncoming(call)
        }
        self.service.onCallAnswered = { [weak self] call in
            self?.handleAnsweredViaCallKit(call)
        }
    }

    // MARK: Observation

    @discardableResult
    func observeSession(_ handler: @escaping (CallSession?) -> Void) -> ObservationToken {
        let id = UUID()
        observers[id] = handler
        handler(activeSession)
        return ObservationToken { [weak self] in self?.observers.removeValue(forKey: id) }
    }

    @discardableResult
    func observeEvents(_ handler: @escaping (InfobipCallEvent) -> Void) -> ObservationToken {
        let id = UUID()
        eventObservers[id] = handler
        return ObservationToken { [weak self] in self?.eventObservers.removeValue(forKey: id) }
    }

    private func notify() {
        delegate?.callClient(self, didUpdate: activeSession)
        observers.values.forEach { $0(activeSession) }
    }

    /// Fan a discrete event out to the delegate, closure observers, and (via `observeEvents`)
    /// the Rx `rx_callEvents` stream.
    private func emitEvent(_ event: InfobipCallEvent) {
        CallLog.debug("event → \(event)", category: "Client")
        delegate?.callClient(self, didReceive: event)
        eventObservers.values.forEach { $0(event) }
    }

    // MARK: Subscriber

    func registerSubscriber(identity: String, displayName: String, token: String, imageURL: String?) async throws {
        CallLog.debug("registerSubscriber(identity: \(identity), hasImage: \(imageURL != nil))", category: "Client")
        guard !identity.isEmpty, !token.isEmpty else { throw InfobipCallError.notRegistered }
        service.registerSubscriber(identity: identity, displayName: displayName, token: token, imageURL: imageURL)
    }

    func updateToken(_ token: String) {
        CallLog.debug("updateToken()", category: "Client")
        service.updateToken(token)
    }

    func clearSubscriber() {
        CallLog.debug("clearSubscriber()", category: "Client")
        service.clearSubscriber()
    }

    func enablePushNotifications(credentials: PKPushCredentials) {
        CallLog.debug("enablePushNotifications(credentials:)", category: "Client")
        service.enablePush(credentials: credentials)
    }

    func disablePushNotifications() {
        CallLog.debug("disablePushNotifications()", category: "Client")
        service.disablePush()
    }

    func activateCallService() {
        CallLog.debug("activateCallService()", category: "Client")
        service.activateCallService()
    }

    func deactivateCallService() {
        CallLog.debug("deactivateCallService()", category: "Client")
        service.deactivateCallService()
    }

    @discardableResult
    func handleIncomingPush(payload: PKPushPayload) -> Bool {
        CallLog.debug("handleIncomingPush(payload:)", category: "Client")
        return service.handleIncomingPush(payload)
    }

    func registerForIncomingCalls() async throws {
        CallLog.debug("registerForIncomingCalls()", category: "Client")
        do {
            try service.registerForIncomingCalls()
        } catch {
            throw InfobipCallError.notRegistered
        }
    }

    @discardableResult
    func handlePushNotification(_ payload: [String: String]) -> Bool {
        CallLog.debug("handlePushNotification()", category: "Client")
        return service.handlePushNotification(payload)
    }

    // MARK: Outgoing

    func startOutgoingCall(destinationIdentity: String, customData: [String: String]) async throws -> CallSession {
        CallLog.debug("startOutgoingCall(destinationIdentity: \(destinationIdentity))", category: "Client")
        try await requireMicrophonePermission()
        let call = try await service.makeCall(destinationIdentity: destinationIdentity, customData: customData)
        lastOutgoing = (destinationIdentity, customData)
        await MainActor.run {
            self.bind(call: call, initialStatus: .connecting)
            self.onPresentCall?(call, .outgoing)
        }
        return activeSession ?? CallSession(activeCall: call, status: .connecting)
    }

    /// Redial the last outgoing call (used by the unreachable screen's "Try again").
    func retryLastCall() async throws -> CallSession {
        guard let last = lastOutgoing else { throw InfobipCallError.nothingToRetry }
        return try await startOutgoingCall(destinationIdentity: last.identity, customData: last.customData)
    }

    // MARK: Incoming

    private func handleIncoming(_ call: ActiveCall) {
        bind(call: call, initialStatus: .ringing)
        // On the CallKit path the system UI is the incoming UI — do NOT present the custom banner.
        // The session is still bound above so host observers see the ringing state; the in-call
        // screen is presented only once the user answers on CallKit (see handleAnsweredViaCallKit).
        if !config.isCallKitEnabled {
            onPresentCall?(call, .incomingBanner)
        }
    }

    /// The user answered an incoming call on the CallKit system UI. Present the in-call screen for
    /// the (already-accepted) call without accepting it again.
    private func handleAnsweredViaCallKit(_ call: ActiveCall) {
        if currentCall !== call {
            bind(call: call, initialStatus: .connecting)
        }
        onPresentCall?(call, .incomingAnswered)
    }

    // MARK: In-call actions

    func acceptIncomingCall() async throws {
        CallLog.debug("acceptIncomingCall()", category: "Client")
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        try await requireMicrophonePermission()
        call.accept()
    }

    func declineIncomingCall() async throws {
        CallLog.debug("declineIncomingCall()", category: "Client")
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.decline()
    }

    func hangUp() async throws {
        CallLog.debug("hangUp()", category: "Client")
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.hangup()
    }

    func setMuted(_ muted: Bool) async throws {
        CallLog.debug("setMuted(\(muted))", category: "Client")
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.setMuted(muted)
    }

    func setSpeakerOn(_ speakerOn: Bool) async throws {
        CallLog.debug("setSpeakerOn(\(speakerOn))", category: "Client")
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.setSpeakerphone(speakerOn)
    }

    // MARK: Binding ActiveCall -> CallSession

    private func bind(call: ActiveCall, initialStatus: CallSession.Status) {
        if let previous = currentObserverId { currentCall?.removeObserver(previous) }
        currentCall = call
        currentNetworkQuality = nil
        activeSession = makeSession(from: call, status: initialStatus)
        if let session = activeSession { emitEvent(.started(session)) }

        currentObserverId = call.observe { [weak self, weak call] event in
            guard let self = self, let call = call else { return }
            switch event {
            case .ringing, .earlyMedia:
                self.updateSession(from: call, status: call.direction == .outgoing ? .calling : nil)
                self.emitEvent(.ringing)
            case .established:
                self.updateSession(from: call, status: .established)
                self.emitEvent(.established)
            case .networkQualityChanged(let quality):
                self.currentNetworkQuality = quality
                self.updateSession(from: call, status: nil)
                self.emitEvent(.networkQualityChanged(quality))
            case .muteChanged(let muted):
                self.updateSession(from: call, status: nil)
                self.emitEvent(.muteChanged(muted))
            case .speakerChanged(let on):
                self.updateSession(from: call, status: nil)
                self.emitEvent(.speakerChanged(on))
            case .audioRouteChanged(let route):
                self.updateSession(from: call, status: nil)
                self.emitEvent(.audioRouteChanged(name: route.name))
            case .hangup(let reason), .error(let reason):
                var ended = self.makeSession(from: call, status: .ended)
                ended.endReason = reason
                self.activeSession = ended
                self.emitEvent(.ended(reason))
                self.currentCall = nil
                self.activeSession = nil
            }
        }
    }

    private func updateSession(from call: ActiveCall, status: CallSession.Status?) {
        guard let current = activeSession else { return }
        activeSession = makeSession(from: call, status: status ?? current.status)
    }

    /// Build a `CallSession` snapshot, carrying the latest observed network quality.
    private func makeSession(from call: ActiveCall, status: CallSession.Status) -> CallSession {
        var session = CallSession(activeCall: call, status: status)
        session.networkQuality = currentNetworkQuality
        return session
    }

    // MARK: Microphone permission

    private func requireMicrophonePermission() async throws {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            return
        case .denied:
            throw InfobipCallError.microphonePermissionDenied
        case .undetermined:
            let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
                session.requestRecordPermission { cont.resume(returning: $0) }
            }
            if !granted { throw InfobipCallError.microphonePermissionDenied }
        @unknown default:
            throw InfobipCallError.microphonePermissionDenied
        }
    }
}

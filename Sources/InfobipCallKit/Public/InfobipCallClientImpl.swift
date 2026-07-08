import Foundation
import AVFoundation

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

    /// Internal hook the center uses to present the built-in UI when a call starts.
    var onPresentCall: ((_ call: ActiveCall, _ isIncoming: Bool) -> Void)?

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
    }

    // MARK: Observation

    @discardableResult
    func observeSession(_ handler: @escaping (CallSession?) -> Void) -> ObservationToken {
        let id = UUID()
        observers[id] = handler
        handler(activeSession)
        return ObservationToken { [weak self] in self?.observers.removeValue(forKey: id) }
    }

    private func notify() {
        delegate?.callClient(self, didUpdate: activeSession)
        observers.values.forEach { $0(activeSession) }
    }

    // MARK: Subscriber

    func registerSubscriber(identity: String, displayName: String, token: String) async throws {
        guard !identity.isEmpty, !token.isEmpty else { throw InfobipCallError.notRegistered }
        service.registerSubscriber(identity: identity, displayName: displayName, token: token)
    }

    func updateToken(_ token: String) {
        service.updateToken(token)
    }

    func clearSubscriber() {
        service.clearSubscriber()
    }

    func registerForIncomingCalls() async throws {
        do {
            try service.registerForIncomingCalls()
        } catch {
            throw InfobipCallError.notRegistered
        }
    }

    @discardableResult
    func handlePushNotification(_ payload: [String: String]) -> Bool {
        service.handlePushNotification(payload)
    }

    // MARK: Outgoing

    func startOutgoingCall(destinationIdentity: String, customData: [String: String]) async throws -> CallSession {
        try await requireMicrophonePermission()
        let call = try await service.makeCall(destinationIdentity: destinationIdentity, customData: customData)
        lastOutgoing = (destinationIdentity, customData)
        await MainActor.run {
            self.bind(call: call, initialStatus: .connecting)
            self.onPresentCall?(call, false)
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
        onPresentCall?(call, true)
    }

    // MARK: In-call actions

    func acceptIncomingCall() async throws {
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        try await requireMicrophonePermission()
        call.accept()
    }

    func declineIncomingCall() async throws {
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.decline()
    }

    func hangUp() async throws {
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.hangup()
    }

    func setMuted(_ muted: Bool) async throws {
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.setMuted(muted)
    }

    func setSpeakerOn(_ speakerOn: Bool) async throws {
        guard let call = currentCall else { throw InfobipCallError.noActiveCall }
        call.setSpeakerphone(speakerOn)
    }

    // MARK: Binding ActiveCall -> CallSession

    private func bind(call: ActiveCall, initialStatus: CallSession.Status) {
        if let previous = currentObserverId { currentCall?.removeObserver(previous) }
        currentCall = call
        activeSession = CallSession(activeCall: call, status: initialStatus)

        currentObserverId = call.observe { [weak self, weak call] event in
            guard let self = self, let call = call else { return }
            switch event {
            case .ringing, .earlyMedia:
                self.updateSession(from: call, status: call.direction == .outgoing ? .calling : nil)
            case .established:
                self.updateSession(from: call, status: .established)
            case .muteChanged, .speakerChanged, .audioRouteChanged:
                self.updateSession(from: call, status: nil)
            case .hangup, .error:
                self.updateSession(from: call, status: .ended)
                self.currentCall = nil
                self.activeSession = nil
            }
        }
    }

    private func updateSession(from call: ActiveCall, status: CallSession.Status?) {
        guard let current = activeSession else { return }
        activeSession = CallSession(activeCall: call, status: status ?? current.status)
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

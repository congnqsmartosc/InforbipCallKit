import Foundation

/// Errors surfaced by ``InfobipCallClient``.
public enum InfobipCallError: LocalizedError {
    case notRegistered
    case noActiveCall
    case microphonePermissionDenied
    case nothingToRetry

    public var errorDescription: String? {
        switch self {
        case .notRegistered:
            return "No subscriber registered. Call registerSubscriber(identity:displayName:token:) first."
        case .noActiveCall:
            return "There is no active call."
        case .microphonePermissionDenied:
            return "Microphone permission is required to make or answer a call."
        case .nothingToRetry:
            return "There is no previous outgoing call to retry."
        }
    }
}

/// Opaque token returned by ``InfobipCallClient/observeSession(_:)``; retain it to keep the
/// observation alive and call ``cancel()`` (or release it) to stop observing.
public final class ObservationToken {
    private var onCancel: (() -> Void)?
    init(onCancel: @escaping () -> Void) { self.onCancel = onCancel }
    public func cancel() {
        onCancel?()
        onCancel = nil
    }
    deinit { cancel() }
}

/// Delegate variant of the active-session stream (see also ``InfobipCallClient/observeSession(_:)``
/// and the optional RxSwift extension `rx_activeSession`).
public protocol InfobipCallClientDelegate: AnyObject {
    /// Called on every `activeSession` change (the latest state snapshot).
    func callClient(_ client: InfobipCallClient, didUpdate session: CallSession?)
    /// Called for each discrete call event (start/end, end reason, signal quality, control
    /// changes). Has a default no-op implementation, so it is optional to adopt.
    func callClient(_ client: InfobipCallClient, didReceive event: InfobipCallEvent)
}

public extension InfobipCallClientDelegate {
    func callClient(_ client: InfobipCallClient, didReceive event: InfobipCallEvent) {}
}

/// The public calling API — a Swift-idiomatic mirror of the Android `InfobipCallClient` interface.
///
/// The host supplies the WebRTC token (obtained from its backend). The built-in UI is presented
/// by ``InfobipCallCenter``; you typically obtain a client via `InfobipCallCenter.client`.
public protocol InfobipCallClient: AnyObject {

    /// Current call state (Android `StateFlow<CallSession?>.value`). `nil` when there is no call.
    var activeSession: CallSession? { get }

    /// Delegate notified on every `activeSession` change.
    var delegate: InfobipCallClientDelegate? { get set }

    /// Closure observer of `activeSession`; fires immediately with the current value.
    @discardableResult
    func observeSession(_ handler: @escaping (CallSession?) -> Void) -> ObservationToken

    /// Closure observer of the discrete call-event stream (see ``InfobipCallEvent``). Unlike
    /// ``observeSession(_:)`` it does not replay a current value — it only fires on new events.
    @discardableResult
    func observeEvents(_ handler: @escaping (InfobipCallEvent) -> Void) -> ObservationToken

    /// Register the logged-in user. `token` must be obtained by the host app (typically from your
    /// backend calling Infobip `POST /webrtc/1/token`). `imageURL` is the subscriber's own avatar;
    /// when set, the framework auto-forwards the subscriber's `displayName` + `imageURL` in the
    /// `customData` of outgoing calls so the callee's screen shows this caller — the host no longer
    /// has to build `customData` by hand.
    func registerSubscriber(identity: String, displayName: String, token: String, imageURL: String?) async throws

    /// Replace the cached subscriber token (e.g. after refresh).
    func updateToken(_ token: String)

    /// Clear subscriber state (e.g. on logout).
    func clearSubscriber()

    /// Start the VoIP push registry at app launch **before** a token is available, so a call that
    /// launched the app from a killed state is still delivered. Call this synchronously from
    /// `application(_:didFinishLaunchingWithOptions:)` when using CallKit / real VoIP push
    /// (`pushConfigId` set). No-op on the foreground `InfobipSimulator` dev path.
    func prepareForIncomingCalls()

    /// Open the channel that receives incoming calls.
    func registerForIncomingCalls() async throws

    /// Returns `true` when `payload` was handled as an Infobip incoming call. On iOS, incoming
    /// calls are normally delivered internally via PushKit; see the implementation notes.
    @discardableResult
    func handlePushNotification(_ payload: [String: String]) -> Bool

    /// Start an outgoing WebRTC call. `customData` is forwarded to the callee (e.g. to pass the
    /// caller's displayName / avatarUrl for the incoming-call screen).
    func startOutgoingCall(destinationIdentity: String, customData: [String: String]) async throws -> CallSession

    func acceptIncomingCall() async throws
    func declineIncomingCall() async throws
    func hangUp() async throws
    func setMuted(_ muted: Bool) async throws
    func setSpeakerOn(_ speakerOn: Bool) async throws
}

public extension InfobipCallClient {
    /// Convenience overload matching the Android default argument.
    func startOutgoingCall(destinationIdentity: String) async throws -> CallSession {
        try await startOutgoingCall(destinationIdentity: destinationIdentity, customData: [:])
    }

    /// Convenience overload without a subscriber avatar (back-compatible with the original API).
    func registerSubscriber(identity: String, displayName: String, token: String) async throws {
        try await registerSubscriber(identity: identity, displayName: displayName, token: token, imageURL: nil)
    }
}

/// Host hand-offs for actions the calling UI surfaces but the app owns (messaging, feedback).
public protocol InfobipCallHostDelegate: AnyObject {
    /// The user tapped "Message" during/after a call. Present your own chat for `peerName`.
    func callRequestsChat(peerName: String)
    /// The post-call feedback sheet was submitted. `rating` is 0…2 (or nil if skipped).
    func callDidFinish(withFeedbackRating rating: Int?, reasons: [String])
}

public extension InfobipCallHostDelegate {
    func callRequestsChat(peerName: String) {}
    func callDidFinish(withFeedbackRating rating: Int?, reasons: [String]) {}
}

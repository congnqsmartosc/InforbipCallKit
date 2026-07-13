import Foundation
import PushKit

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

    /// CallKit / real VoIP push path: the **host app** owns the `PKPushRegistry`. Call this from the
    /// host's `PKPushRegistryDelegate.pushRegistry(_:didUpdate:for:)` (VoIP type) to bind the device
    /// token to Infobip so its server can send VoIP pushes. Safe to call before or after
    /// ``registerSubscriber(identity:displayName:token:imageURL:)`` — binding happens once both the
    /// credentials and the subscriber token are available.
    func enablePushNotifications(credentials: PKPushCredentials)

    /// Unbind VoIP push from Infobip. Call from `pushRegistry(_:didInvalidatePushTokenFor:)` or on
    /// logout (``clearSubscriber()`` also unbinds).
    func disablePushNotifications()

    /// Create and register the CallKit provider (`CXProvider`) — call when the app actually starts
    /// using Infobip (e.g. after a remote-config / login check selects the Infobip calling path).
    /// You can create ``InfobipCallCenter`` and the host `PKPushRegistry` earlier; CallKit itself is
    /// only set up here. No-op when CallKit isn't enabled by config, or when already active.
    func activateCallService()

    /// Tear down the CallKit provider so another calling SDK can own CallKit, or on logout. Ends any
    /// in-flight calls and releases the `CXProvider`. Safe to call when already inactive.
    func deactivateCallService()

    /// CallKit / real VoIP push path: hand a VoIP `PKPushPayload` the host received off to Infobip,
    /// which reports the incoming call to CallKit and starts the WebRTC call.
    ///
    /// - Important: Call this **synchronously** from the host's
    ///   `pushRegistry(_:didReceiveIncomingPushWith:for:completion:)` and only call `completion()`
    ///   afterwards. iOS terminates a VoIP-push-launched app that does not report a call to CallKit
    ///   before the completion handler returns.
    /// - Returns: `true` when the payload was an Infobip incoming call.
    @discardableResult
    func handleIncomingPush(payload: PKPushPayload) -> Bool

    /// Open the channel that receives incoming calls. Only needed on the foreground `InfobipSimulator`
    /// dev path (`pushConfigId == nil`); a no-op on the CallKit/APNs path, where push is host-driven.
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

/// Host hand-offs for actions the calling UI surfaces but the app owns (messaging).
public protocol InfobipCallHostDelegate: AnyObject {
    /// The user tapped "Message" during/after a call. Present your own chat for `peerName`.
    func callRequestsChat(peerName: String)
}

public extension InfobipCallHostDelegate {
    func callRequestsChat(peerName: String) {}
}

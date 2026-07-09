import Foundation

/// Discrete events emitted over the life of a call, delivered to the host via
/// ``InfobipCallClientDelegate/callClient(_:didReceive:)``, ``InfobipCallClient/observeEvents(_:)``,
/// and (with the `InfobipCallKit/Rx` subspec) `rx_callEvents`.
///
/// This is the event-oriented companion to ``InfobipCallClient/activeSession`` (which carries the
/// current *state*). Use events for one-shot signals (call started/ended, end reason, signal
/// quality changes) and `activeSession` for the latest snapshot.
public enum InfobipCallEvent: Equatable {
    /// A call just began — outgoing placed or incoming received. Carries the initial snapshot.
    case started(CallSession)
    /// The callee's device is ringing (outgoing) or early media arrived.
    case ringing
    /// The media session is being established (after accept / on outgoing setup).
    case connecting
    /// Both sides are connected; `CallSession.durationSeconds` is now running.
    case established
    /// The call finished — normal hangup or error. See ``CallEndReason``.
    case ended(CallEndReason)
    /// The connection quality changed (SDK network-quality signal).
    case networkQualityChanged(InfobipNetworkQuality)
    /// The local microphone mute state changed.
    case muteChanged(Bool)
    /// The speakerphone state changed.
    case speakerChanged(Bool)
    /// The active audio output route changed (name of the now-active route).
    case audioRouteChanged(name: String)
}

/// Why a call ended, mapped from the Infobip SDK's `ErrorCode`.
public struct CallEndReason: Equatable {
    /// Numeric SDK code (`ErrorCode.id`).
    public let code: Int
    /// Machine-readable name, e.g. `"NORMAL_HANGUP"`, `"NO_ANSWER"`, `"BUSY"` (`ErrorCode.name`).
    public let name: String
    /// Human-readable message (`ErrorCode.message`).
    public let message: String
    /// `true` when the call ended via an error event rather than a normal hangup.
    public let isError: Bool

    public init(code: Int, name: String, message: String, isError: Bool) {
        self.code = code
        self.name = name
        self.message = message
        self.isError = isError
    }
}

/// Connection quality, a 1:1 mirror of the SDK's `NetworkQuality` (never leaks `InfobipRTC` types).
public enum InfobipNetworkQuality: Int, Equatable {
    case bad = 1
    case poor
    case fair
    case good
    case excellent
}

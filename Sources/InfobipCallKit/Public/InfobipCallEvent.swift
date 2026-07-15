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
    /// This device lost its network and the SDK is trying to re-establish the call. The call is not
    /// over — show a "Reconnecting…" state and wait for ``reconnected`` or ``ended``.
    case reconnecting
    /// This device's connection recovered after ``reconnecting``.
    case reconnected
    /// The remote party lost their network connection.
    case remoteDisconnected
    /// The remote party's connection recovered.
    case remoteReconnected
    /// The local microphone mute state changed.
    case muteChanged(Bool)
    /// The speakerphone state changed.
    case speakerChanged(Bool)
    /// The active audio output route changed (name of the now-active route).
    case audioRouteChanged(name: String)
}

/// Why a call ended, mapped from the Infobip SDK's `ErrorCode`.
public struct CallEndReason: Equatable {
    /// Numeric SDK code (`ErrorCode.id`), e.g. `10000` NORMAL_HANGUP, `10307` REQUEST_TIMEOUT.
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

    /// Semantic classification of the raw SDK code/name, so hosts don't hard-code Infobip numbers.
    /// Derived from the SDK error name, with the code's group (`101xx` handset, `102xx` user,
    /// `103xx` operator) as a fallback for undocumented codes.
    public enum Category: Equatable {
        case normal          // NORMAL_HANGUP, ANSWERED_ELSEWHERE, HUMAN/MACHINE_DETECTED, MAX_DURATION_REACHED
        case noAnswer        // NO_ANSWER
        case busy            // BUSY
        case declined        // REJECTED — callee declined
        case cancelled       // CANCELLED — caller cancelled before routing
        case unavailable     // callee offline / TEMPORARILY_UNAVAILABLE / REQUEST_TIMEOUT (unreachable)
        case deviceError     // DEVICE_FORBIDDEN / DEVICE_NOT_FOUND / DEVICE_UNAVAILABLE (mic/camera)
        case mediaError      // MEDIA_ERROR — audio/media problem during the call
        case unauthorized    // UNAUTHENTICATED / FORBIDDEN — caller not authorized
        case error           // any other operator/error condition
    }

    /// See ``Category``.
    public var category: Category {
        switch name.uppercased() {
        case "NORMAL_HANGUP", "ANSWERED_ELSEWHERE", "HUMAN_DETECTED", "MACHINE_DETECTED", "MAX_DURATION_REACHED":
            return .normal
        case "NO_ANSWER":                                     return .noAnswer
        case "BUSY":                                          return .busy
        case "REJECTED":                                      return .declined
        case "CANCELLED":                                     return .cancelled
        case "TEMPORARILY_UNAVAILABLE", "REQUEST_TIMEOUT":    return .unavailable
        case "DEVICE_FORBIDDEN", "DEVICE_NOT_FOUND", "DEVICE_UNAVAILABLE":
            return .deviceError
        case "MEDIA_ERROR":                                   return .mediaError
        case "FORBIDDEN", "UNAUTHENTICATED":                  return .unauthorized
        default:
            switch code / 100 {   // group by hundreds digit for undocumented codes
            case 101: return .deviceError
            case 102: return .unavailable
            case 103: return .error
            default:  return isError ? .error : .normal
            }
        }
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

import Foundation

/// Immutable snapshot of the current call, mirroring Android's `CallSession` state holder.
///
/// A new value is emitted through ``InfobipCallClient/activeSession`` (and the delegate / closure /
/// Rx observers) whenever the call's state changes. Actions live on ``InfobipCallClient`` — this
/// type only carries state.
public struct CallSession: Equatable {

    public enum Direction: Equatable {
        case incoming
        case outgoing
    }

    public enum Status: Equatable {
        /// Incoming call awaiting the user's answer.
        case ringing
        /// Outgoing/answered call establishing the media session.
        case connecting
        /// Outgoing call: the callee's device is ringing.
        case calling
        /// Both sides connected; `durationSeconds` is running.
        case established
        /// Call finished (hung up, declined, error, or unreachable).
        case ended
    }

    /// SDK call id.
    public let id: String
    public let direction: Direction
    public internal(set) var status: Status

    /// Counterpart identity (raw WebRTC identifier).
    public let counterpartIdentity: String
    /// Counterpart display name (from the token endpoint, else `customData`, else identity).
    public let counterpartDisplayName: String
    /// Counterpart avatar (from `customData`), if provided.
    public let counterpartAvatarURL: URL?

    public internal(set) var isMuted: Bool
    public internal(set) var isSpeakerOn: Bool
    public internal(set) var durationSeconds: Int

    /// Latest connection quality reported by the SDK, if any has been observed yet.
    public internal(set) var networkQuality: InfobipNetworkQuality?

    /// Why the call ended. Non-nil only when `status == .ended`.
    public internal(set) var endReason: CallEndReason?

    /// Available audio outputs for this call (for a custom audio-route picker).
    public internal(set) var audioRoutes: [AudioRoute]

    /// The currently active audio output, if known.
    public internal(set) var activeAudioRoute: AudioRoute?
}

extension CallSession {
    /// Builds a snapshot from the internal `ActiveCall`.
    init(activeCall: ActiveCall, status: Status) {
        self.id = activeCall.callId
        self.direction = activeCall.direction == .incoming ? .incoming : .outgoing
        self.status = status
        self.counterpartIdentity = activeCall.counterpartIdentity
        self.counterpartDisplayName = activeCall.counterpartName
        self.counterpartAvatarURL = activeCall.avatarURL
        self.isMuted = activeCall.isMuted
        self.isSpeakerOn = activeCall.isSpeakerOn
        self.durationSeconds = activeCall.durationSeconds
        self.networkQuality = nil
        self.endReason = nil
        self.audioRoutes = activeCall.audioRoutes.map(AudioRoute.init)
        self.activeAudioRoute = activeCall.activeAudioRoute.map(AudioRoute.init)
    }
}

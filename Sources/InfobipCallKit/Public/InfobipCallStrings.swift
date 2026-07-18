import Foundation

/// Every user-facing string shown by the built-in call screens. Defaults are English; override any
/// subset to localize or rebrand. (The pod ships no `.strings` files — text comes from here.)
public struct InfobipCallStrings {

    // In-call screen
    public var callTitle: String
    public var statusConnecting: String
    public var statusRinging: String
    public var statusReconnecting: String
    public var statusIncoming: String
    public var statusCallEnded: String

    // Controls
    public var speaker: String
    public var mute: String
    public var unmute: String
    public var bluetooth: String
    public var headphones: String
    public var audioGeneric: String

    // Audio-route sheet
    public var audioSourceTitle: String
    public var routeBuiltIn: String        // e.g. "iPhone"
    public var routeSpeaker: String        // external speaker

    // Incoming banner
    public var incomingBrandLabel: String

    // Unreachable outcome
    public var unreachableTitle: String
    public var unreachableHeadline: String
    public var unreachableSubtitle: String
    public var tryAgain: String
    public var sendMessage: String

    // Microphone-permission alert
    public var micPermissionTitle: String
    public var micPermissionMessage: String
    public var micOpenSettings: String
    public var micDismiss: String

    public init(
        callTitle: String = "Call",
        statusConnecting: String = "Connecting…",
        statusRinging: String = "Ringing…",
        statusReconnecting: String = "Reconnecting…",
        statusIncoming: String = "Calling you",
        statusCallEnded: String = "Call ended",
        speaker: String = "Speaker",
        mute: String = "Mute",
        unmute: String = "Unmute",
        bluetooth: String = "Bluetooth",
        headphones: String = "Headphones",
        audioGeneric: String = "Audio",
        audioSourceTitle: String = "Audio source",
        routeBuiltIn: String = "iPhone",
        routeSpeaker: String = "Speaker",
        incomingBrandLabel: String = "Incoming call",
        unreachableTitle: String = "Call",
        unreachableHeadline: String = "The recipient did not answer",
        unreachableSubtitle: String = "They may be unavailable right now.\nTry again?",
        tryAgain: String = "Try again",
        sendMessage: String = "Send a message",
        micPermissionTitle: String = "Microphone access needed",
        micPermissionMessage: String = "Please allow microphone access in Settings to make calls.",
        micOpenSettings: String = "Open Settings",
        micDismiss: String = "Dismiss"
    ) {
        self.callTitle = callTitle
        self.statusConnecting = statusConnecting
        self.statusRinging = statusRinging
        self.statusReconnecting = statusReconnecting
        self.statusIncoming = statusIncoming
        self.statusCallEnded = statusCallEnded
        self.speaker = speaker
        self.mute = mute
        self.unmute = unmute
        self.bluetooth = bluetooth
        self.headphones = headphones
        self.audioGeneric = audioGeneric
        self.audioSourceTitle = audioSourceTitle
        self.routeBuiltIn = routeBuiltIn
        self.routeSpeaker = routeSpeaker
        self.incomingBrandLabel = incomingBrandLabel
        self.unreachableTitle = unreachableTitle
        self.unreachableHeadline = unreachableHeadline
        self.unreachableSubtitle = unreachableSubtitle
        self.tryAgain = tryAgain
        self.sendMessage = sendMessage
        self.micPermissionTitle = micPermissionTitle
        self.micPermissionMessage = micPermissionMessage
        self.micOpenSettings = micOpenSettings
        self.micDismiss = micDismiss
    }

    public static let `default` = InfobipCallStrings()
}

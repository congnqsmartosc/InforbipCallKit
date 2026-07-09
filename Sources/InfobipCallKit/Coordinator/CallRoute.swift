import XCoordinator

/// Mode for the Free-call screen — carries the live `ActiveCall`.
enum FreeCallMode {
    /// Incoming call. `autoAccept == true` when the user already tapped accept on the banner.
    case incoming(ActiveCall, autoAccept: Bool)
    /// Incoming call already answered on the CallKit system UI — show the in-call screen without
    /// accepting again.
    case incomingAnswered(ActiveCall)
    /// Outgoing call (already created via the client).
    case outgoing(ActiveCall)
}

/// Internal navigation routes for the built-in calling UI, driven by XCoordinator.
/// Only call-related screens live here; host concerns (messaging, dialing, feedback delivery)
/// are surfaced to the app through `InfobipCallHostDelegate` instead of being routes.
enum CallRoute: Route {
    // Incoming
    case incomingCall(ActiveCall)                 // banner + ringtone
    case answerIncoming(ActiveCall)               // accept -> mic permission -> call screen
    case declineIncoming(ActiveCall)              // decline on banner
    case freeCall(FreeCallMode)                   // full call screen (incoming/outgoing)

    // In-call
    case audioRoutes(ActiveCall)                  // audio-source sheet
    case keypad(callerName: String)               // in-call DTMF keypad
    case closeKeypad

    // Termination
    case cancelCall                               // ended before connecting -> just close
    case endCall                                  // connected call ended -> feedback screen
    case finishCall                               // close feedback -> tear down
    case callUnreachable(name: String, destinationIdentity: String)  // outgoing refused/no-answer
    case retryCall(destinationIdentity: String)   // redial from the unreachable screen
    case backToHome                               // close current screen -> tear down

    // Host hand-offs
    case openChat(peerName: String)               // -> InfobipCallHostDelegate

    // Permission / system
    case micDenied
    case openSettings

    // Present/dismiss helpers
    case dismiss
}

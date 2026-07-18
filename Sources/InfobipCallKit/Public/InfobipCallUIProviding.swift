import UIKit

/// Supply your own view controllers for the call screens. Set `InfobipCallCenter.uiProvider`.
/// Each factory is optional — return `nil` (the default) to use the built-in screen (styled by
/// ``InfobipCallAppearance`` / ``InfobipCallStrings``), or return a `UIViewController` to fully own
/// that screen. The pod keeps owning call state, CallKit, ringtone, and navigation/teardown — your
/// controller only owns the pixels and drives the call through the passed-in context.
public protocol InfobipCallUIProviding: AnyObject {
    /// The in-call screen (outgoing / answered incoming). Call ``InCallContext/start()`` from your
    /// controller's `viewDidLoad`, bind the `on…` callbacks, and drive actions via the context.
    func makeInCallScreen(_ context: InCallContext) -> UIViewController?

    /// The incoming-call banner (foreground `InfobipSimulator` dev path; CallKit shows system UI).
    func makeIncomingBanner(_ context: IncomingCallContext) -> UIViewController?

    /// The audio-route picker sheet.
    func makeAudioRouteSheet(_ context: AudioRouteContext) -> UIViewController?

    /// The "recipient unavailable" outcome screen for a failed outgoing call.
    func makeUnreachableScreen(_ context: UnreachableContext) -> UIViewController?

    /// The in-call DTMF keypad.
    func makeKeypad(_ context: KeypadContext) -> UIViewController?
}

public extension InfobipCallUIProviding {
    func makeInCallScreen(_ context: InCallContext) -> UIViewController? { nil }
    func makeIncomingBanner(_ context: IncomingCallContext) -> UIViewController? { nil }
    func makeAudioRouteSheet(_ context: AudioRouteContext) -> UIViewController? { nil }
    func makeUnreachableScreen(_ context: UnreachableContext) -> UIViewController? { nil }
    func makeKeypad(_ context: KeypadContext) -> UIViewController? { nil }
}

/// State + actions for a custom in-call screen. A public facade over the pod's in-call driver, so
/// your controller never touches pod internals. Retain it for the controller's lifetime.
public final class InCallContext {

    /// Call phase, mirroring the built-in screen's states.
    public enum Phase: Equatable {
        case incoming      // ringing, awaiting the user's accept/decline
        case connecting
        case ringing       // outgoing: the callee's device is ringing
        case established
        case ended
    }

    private let viewModel: FreeCallViewModel

    // MARK: Display data
    public var callerName: String { viewModel.callerName }
    public var avatarURL: URL? { viewModel.avatarURL }
    public var isMuted: Bool { viewModel.isMuted }
    public var isSpeakerOn: Bool { viewModel.isSpeakerOn }
    /// Available audio outputs (build a custom picker, or call ``selectAudioRoute(id:)``).
    public var audioRoutes: [AudioRoute] { viewModel.audioRoutes.map(AudioRoute.init) }

    // MARK: Bindings (set these before / in your viewDidLoad)
    public var onPhaseChange: ((Phase) -> Void)?
    public var onStatusText: ((String) -> Void)?
    public var onMuteChange: ((Bool) -> Void)?
    public var onAudioRouteChange: ((AudioRoute) -> Void)?

    init(viewModel: FreeCallViewModel) {
        self.viewModel = viewModel
        viewModel.onPhaseChange = { [weak self] phase in self?.onPhaseChange?(Phase(phase)) }
        viewModel.onStatusText = { [weak self] text in self?.onStatusText?(text) }
        viewModel.onMuteChange = { [weak self] muted in self?.onMuteChange?(muted) }
        viewModel.onAudioRouteChange = { [weak self] route in self?.onAudioRouteChange?(AudioRoute(route)) }
    }

    // MARK: Lifecycle + actions
    /// Kick off the call flow (auto-accepts an already-answered incoming, sets the initial phase).
    /// Call once from your controller's `viewDidLoad`.
    public func start() { viewModel.viewDidLoad() }

    public func accept() { viewModel.accept() }
    /// Decline / cancel / end depending on the current phase (same logic as the built-in end button).
    public func hangUp() { viewModel.hangUp() }
    public func toggleMute() { viewModel.toggleMute() }
    public func toggleSpeaker() { viewModel.toggleSpeaker() }
    /// Present the (built-in or custom) audio-route picker.
    public func openAudioRoutes() { viewModel.openAudioRoutes() }
    public func selectAudioRoute(id: String) { viewModel.selectAudioRoute(id: id) }
}

private extension InCallContext.Phase {
    init(_ phase: FreeCallViewModel.Phase) {
        switch phase {
        case .incoming:    self = .incoming
        case .connecting:  self = .connecting
        case .ringing:     self = .ringing
        case .established: self = .established
        case .ended:       self = .ended
        }
    }
}

/// State + actions for a custom incoming-call banner.
public final class IncomingCallContext {
    public let callerName: String
    public let avatarURL: URL?
    private let viewModel: IncomingCallViewModel

    init(viewModel: IncomingCallViewModel) {
        self.viewModel = viewModel
        self.callerName = viewModel.callerName
        self.avatarURL = viewModel.avatarURL
    }

    /// Accept — asks mic permission then opens the in-call screen.
    public func accept() { viewModel.accept() }
    /// Decline the incoming call.
    public func decline() { viewModel.decline() }
    /// Expand to the full incoming screen without answering (ringing continues).
    public func openFullScreen() { viewModel.openFullScreen() }
}

/// State + actions for a custom audio-route picker.
public final class AudioRouteContext {
    public let routes: [AudioRoute]
    private let onSelect: (String) -> Void
    private let onDismiss: () -> Void

    init(routes: [AudioRoute], onSelect: @escaping (String) -> Void, onDismiss: @escaping () -> Void) {
        self.routes = routes
        self.onSelect = onSelect
        self.onDismiss = onDismiss
    }

    public func select(id: String) { onSelect(id) }
    public func dismiss() { onDismiss() }
}

/// State + actions for a custom "recipient unavailable" outcome screen.
public final class UnreachableContext {
    public let peerName: String
    private let onRetry: () -> Void
    private let onClose: () -> Void

    init(peerName: String, onRetry: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.peerName = peerName
        self.onRetry = onRetry
        self.onClose = onClose
    }

    /// Redial the same destination.
    public func retry() { onRetry() }
    /// Dismiss and tear down.
    public func close() { onClose() }
}

/// State + actions for a custom in-call DTMF keypad.
public final class KeypadContext {
    public let callerName: String
    private let onClose: () -> Void

    init(callerName: String, onClose: @escaping () -> Void) {
        self.callerName = callerName
        self.onClose = onClose
    }

    /// Close the keypad and return to the in-call screen.
    public func close() { onClose() }
}

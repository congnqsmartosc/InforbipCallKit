import UIKit

/// Entry point for InfobipCallKit. Owns the ``InfobipCallClient`` and presents the built-in
/// calling UI on a dedicated overlay window — so it never interferes with the host's navigation.
///
/// ```swift
/// let center = InfobipCallCenter(config: .init())
/// center.install(on: window)          // once, from SceneDelegate
/// center.hostDelegate = self
/// // later:
/// try await center.client.registerSubscriber(identity: id, displayName: name, token: token)
/// try await center.client.registerForIncomingCalls()
/// try await center.client.startOutgoingCall(destinationIdentity: "driver", customData: [...])
/// ```
public final class InfobipCallCenter {

    /// The calling API. Mirrors the Android `InfobipCallClient`.
    public let client: InfobipCallClient

    /// Host hand-offs (open chat, feedback delivery).
    public weak var hostDelegate: InfobipCallHostDelegate? {
        didSet { coordinator.hostDelegate = hostDelegate }
    }

    private let impl: InfobipCallClientImpl
    private let coordinator: CallCoordinator
    private weak var hostWindow: UIWindow?
    private var callWindow: UIWindow?

    public init(config: InfobipCallConfig = InfobipCallConfig()) {
        CallTheme.current = config.theme

        let service = CallService(config: config)
        let impl = InfobipCallClientImpl(service: service, config: config)
        self.impl = impl
        self.client = impl
        self.coordinator = CallCoordinator(config: config)

        coordinator.onFinished = { [weak self] in self?.hideCallUI() }
        coordinator.onRetry = { [weak self] _ in
            Task { @MainActor in _ = try? await self?.impl.retryLastCall() }
        }
        impl.onPresentCall = { [weak self] call, isIncoming in
            self?.presentCall(call, isIncoming: isIncoming)
        }
    }

    /// Provide the host's key window once (typically from `SceneDelegate`). Used to derive the
    /// window scene for the overlay call window.
    public func install(on window: UIWindow) {
        hostWindow = window
    }

    // MARK: - Presentation

    // Always invoked on the main thread (from the client's main-dispatched incoming callback and
    // its `MainActor.run` outgoing path).
    private func presentCall(_ call: ActiveCall, isIncoming: Bool) {
        showCallUI()
        if isIncoming {
            coordinator.trigger(.incomingCall(call))
        } else {
            coordinator.trigger(.freeCall(.outgoing(call)))
        }
    }

    private func showCallUI() {
        guard callWindow == nil else { return }
        let window: UIWindow
        if let scene = hostWindow?.windowScene {
            window = UIWindow(windowScene: scene)
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window.windowLevel = .normal + 1
        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()
        callWindow = window
    }

    private func hideCallUI() {
        callWindow?.isHidden = true
        callWindow = nil
        hostWindow?.makeKeyAndVisible()
    }
}

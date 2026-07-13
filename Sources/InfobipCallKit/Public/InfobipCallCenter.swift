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

    /// A call answered on CallKit while the app wasn't foreground-active yet — its in-call screen is
    /// presented once the app becomes active (see `presentDeferredAnsweredCallIfNeeded`).
    private var deferredAnsweredCall: ActiveCall?

    public init(config: InfobipCallConfig = InfobipCallConfig()) {
        CallLog.isEnabled = config.isLoggingEnabled
        CallTheme.current = config.theme
        CallLog.debug("InfobipCallCenter initialized (pushConfigId=\(config.pushConfigId ?? "nil"))", category: "Center")

        let service = CallService(config: config)
        let impl = InfobipCallClientImpl(service: service, config: config)
        self.impl = impl
        self.client = impl
        self.coordinator = CallCoordinator(config: config)

        coordinator.onFinished = { [weak self] in self?.hideCallUI() }
        coordinator.onRetry = { [weak self] _ in
            Task { @MainActor in _ = try? await self?.impl.retryLastCall() }
        }
        impl.onPresentCall = { [weak self] call, presentation in
            self?.present(call, presentation)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Provide the host's key window once (typically from `SceneDelegate`). Used to derive the
    /// window scene for the overlay call window.
    public func install(on window: UIWindow) {
        hostWindow = window
    }

    /// Set up CallKit (create the `CXProvider`) — call when the app actually starts using Infobip.
    /// You may create the center and the host `PKPushRegistry` earlier; CallKit is only created here.
    /// No-op when CallKit isn't enabled by config, or when already active. Convenience for
    /// `client.activateCallService()`.
    public func activateCallService() {
        client.activateCallService()
    }

    /// Tear CallKit down (release the `CXProvider`) so another calling SDK can own CallKit, or on
    /// logout. Ends any in-flight calls. Convenience for `client.deactivateCallService()`.
    public func deactivateCallService() {
        client.deactivateCallService()
    }

    // MARK: - Presentation

    // Always invoked on the main thread (from the client's main-dispatched callbacks and its
    // `MainActor.run` outgoing path).
    private func present(_ call: ActiveCall, _ presentation: InfobipCallClientImpl.Presentation) {
        switch presentation {
        case .incomingBanner:
            showCallUI()
            coordinator.trigger(.incomingCall(call))
        case .outgoing:
            showCallUI()
            coordinator.trigger(.freeCall(.outgoing(call)))
        case .incomingAnswered:
            // Answered on CallKit. Show the in-call screen only when the app is foreground-active;
            // otherwise defer until it becomes active (killed/locked answer has no scene yet).
            if UIApplication.shared.applicationState == .active {
                showCallUI()
                coordinator.trigger(.freeCall(.incomingAnswered(call)))
            } else {
                deferredAnsweredCall = call
            }
        }
    }

    @objc private func appDidBecomeActive() {
        guard let call = deferredAnsweredCall else { return }
        deferredAnsweredCall = nil
        showCallUI()
        coordinator.trigger(.freeCall(.incomingAnswered(call)))
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

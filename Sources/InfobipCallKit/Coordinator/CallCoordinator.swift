import UIKit
import AVFoundation
import XCoordinator

/// Internal coordinator that owns the calling UI navigation, ringtone lifecycle, and mic-permission
/// prompts. It lives inside `InfobipCallCenter`'s overlay window and never touches host navigation.
///
/// ViewControllers never present/push themselves — they `router.trigger(.route)` and every
/// transition is centralized in `prepareTransition(for:)`.
final class CallCoordinator: NavigationCoordinator<CallRoute> {

    private let config: InfobipCallConfig
    private let ringtonePlayer = RingtonePlayer()

    /// Called when the whole call flow ends — the center hides/tears down the overlay window.
    var onFinished: (() -> Void)?
    /// Redial request from the unreachable screen — the center forwards to the client.
    var onRetry: ((_ destinationIdentity: String) -> Void)?
    /// Host hand-offs (open chat, etc).
    weak var hostDelegate: InfobipCallHostDelegate?

    /// Optional host UI provider for custom call screens (Layer 2).
    weak var uiProvider: InfobipCallUIProviding?

    /// Retains the drivers behind host-supplied custom screens for the call's lifetime (so a host
    /// that doesn't itself retain the context can't cause its driver to deallocate). Cleared on teardown.
    private var retainedContexts: [AnyObject] = []

    init(config: InfobipCallConfig) {
        self.config = config
        super.init(initialRoute: nil)
        rootViewController.setNavigationBarHidden(true, animated: false)
    }

    override func prepareTransition(for route: CallRoute) -> NavigationTransition {
        switch route {
        case .incomingCall(let call):
            return showIncomingBanner(for: call)

        case .answerIncoming(let call):
            ringtonePlayer.stop()
            requestMicPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.trigger(.freeCall(.incoming(call, autoAccept: true)))
                } else {
                    call.decline()
                    self.rootViewController.dismiss(animated: true) {
                        self.trigger(.micDenied)
                    }
                }
            }
            return .none()

        case .declineIncoming(let call):
            ringtonePlayer.stop()
            call.decline()
            return dismissPresentedThenMaybeFinish()

        case .freeCall(let mode):
            return showFreeCall(mode: mode)

        case .audioRoutes(let call):
            let context = AudioRouteContext(
                routes: call.audioRoutes.map(AudioRoute.init),
                onSelect: { [weak call] id in call?.selectAudioRoute(id: id) },
                onDismiss: { [weak self] in self?.trigger(.dismiss) }
            )
            let vc: UIViewController
            if let custom = uiProvider?.makeAudioRouteSheet(context) {
                retainedContexts.append(context)
                vc = custom
            } else {
                let sheet = AudioRouteSheetViewController(call: call)
                sheet.router = unownedRouter
                vc = sheet
            }
            return .present(vc)

        case .keypad(let callerName):
            let context = KeypadContext(callerName: callerName, onClose: { [weak self] in self?.trigger(.closeKeypad) })
            let vc: UIViewController
            if let custom = uiProvider?.makeKeypad(context) {
                retainedContexts.append(context)
                vc = custom
            } else {
                let pad = KeypadViewController(callerName: callerName)
                pad.router = unownedRouter
                vc = pad
            }
            return .push(vc)

        case .closeKeypad:
            return .pop()

        case .cancelCall:
            ringtonePlayer.stop()
            finishFlow()
            return .none()

        case .callUnreachable(let name, let destinationIdentity):
            let context = UnreachableContext(
                peerName: name,
                onRetry: { [weak self] in self?.trigger(.retryCall(destinationIdentity: destinationIdentity)) },
                onClose: { [weak self] in self?.trigger(.backToHome) }
            )
            let vc: UIViewController
            if let custom = uiProvider?.makeUnreachableScreen(context) {
                retainedContexts.append(context)
                vc = custom
            } else {
                let unreachable = CallUnreachableViewController(callerName: name, destinationIdentity: destinationIdentity)
                unreachable.router = unownedRouter
                vc = unreachable
            }
            // Replace the dead in-call screen (built-in or custom) so back-swipe can't return to it.
            var stack = rootViewController.viewControllers
            if !stack.isEmpty { stack.removeLast() }
            stack.append(vc)
            rootViewController.setViewControllers(stack, animated: true)
            return .none()

        case .retryCall(let destinationIdentity):
            // Clear the unreachable screen; the client re-presents a fresh call screen.
            rootViewController.setViewControllers([], animated: false)
            onRetry?(destinationIdentity)
            return .none()

        case .backToHome:
            ringtonePlayer.stop()
            finishFlow()
            return .none()

        case .openChat(let peerName):
            hostDelegate?.callRequestsChat(peerName: peerName)
            return .none()

        case .micDenied:
            showMicDeniedAlert()
            return .none()

        case .openSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            return .none()

        case .dismiss:
            return dismissPresentedThenMaybeFinish()
        }
    }

    // MARK: - Incoming

    private func showIncomingBanner(for call: ActiveCall) -> NavigationTransition {
        ringtonePlayer.start()
        call.observe { [weak self] event in
            switch event {
            case .established, .hangup, .error:
                self?.ringtonePlayer.stop()
            default:
                break
            }
        }

        let viewModel = IncomingCallViewModel(call: call, router: unownedRouter)
        let banner: UIViewController
        let context = IncomingCallContext(viewModel: viewModel)
        if let custom = uiProvider?.makeIncomingBanner(context) {
            retainedContexts.append(context)
            banner = custom
        } else {
            banner = IncomingCallViewController(viewModel: viewModel)
        }

        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: false) { [weak self] in
                self?.rootViewController.present(banner, animated: true)
            }
            return .none()
        }
        return .present(banner)
    }

    // MARK: - Free call

    private func showFreeCall(mode: FreeCallMode) -> NavigationTransition {
        let call: ActiveCall
        let autoAccept: Bool
        let alreadyAnswered: Bool
        switch mode {
        case .incoming(let incomingCall, let accept):
            call = incomingCall
            autoAccept = accept
            alreadyAnswered = false
        case .incomingAnswered(let answeredCall):
            // Answered on CallKit already — show the in-call screen without re-accepting.
            call = answeredCall
            autoAccept = false
            alreadyAnswered = true
        case .outgoing(let outgoingCall):
            call = outgoingCall
            autoAccept = false
            alreadyAnswered = false
            // Ringback "beep… beep…" while the callee's phone rings; stops on media/connect/end.
            call.observe { [weak self] event in
                switch event {
                case .ringing:
                    self?.ringtonePlayer.startRingback()
                case .earlyMedia, .established, .hangup, .error:
                    self?.ringtonePlayer.stopRingback()
                default:
                    break
                }
            }
        }

        let viewModel = FreeCallViewModel(call: call, autoAccept: autoAccept, alreadyAnswered: alreadyAnswered, router: unownedRouter)

        // Layer 2: let the host fully own the in-call screen. The context wraps the same driver, so
        // routing/teardown are unchanged; the host VC calls `context.start()` in its viewDidLoad.
        let vc: UIViewController
        let context = InCallContext(viewModel: viewModel)
        if let custom = uiProvider?.makeInCallScreen(context) {
            retainedContexts.append(context)   // retain the driver for the call's lifetime
            vc = custom
        } else {
            vc = FreeCallViewController(viewModel: viewModel)
        }

        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: true) { [weak self] in
                self?.rootViewController.pushViewController(vc, animated: true)
            }
            return .none()
        }
        return .push(vc)
    }

    // MARK: - Teardown

    private func finishFlow() {
        ringtonePlayer.stop()
        retainedContexts.removeAll()
        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: false, completion: nil)
        }
        rootViewController.setViewControllers([], animated: false)
        onFinished?()
    }

    /// Dismiss any presented screen (audio sheet / banner). If that leaves the call stack empty
    /// (e.g. the incoming banner was the only screen), end the whole flow and tear down the window.
    private func dismissPresentedThenMaybeFinish() -> NavigationTransition {
        guard rootViewController.presentedViewController != nil else {
            if rootViewController.viewControllers.isEmpty { finishFlow() }
            return .none()
        }
        rootViewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if self.rootViewController.viewControllers.isEmpty { self.finishFlow() }
        }
        return .none()
    }

    // MARK: - Permission

    private func requestMicPermission(_ completion: @escaping (Bool) -> Void) {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            session.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        @unknown default:
            completion(false)
        }
    }

    private func showMicDeniedAlert() {
        let strings = CallStrings.current
        let alert = UIAlertController(
            title: strings.micPermissionTitle,
            message: strings.micPermissionMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: strings.micOpenSettings, style: .default) { [weak self] _ in
            self?.trigger(.openSettings)
        })
        alert.addAction(UIAlertAction(title: strings.micDismiss, style: .cancel) { [weak self] _ in
            self?.trigger(.backToHome)
        })
        rootViewController.present(alert, animated: true)
    }
}

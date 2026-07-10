import UIKit
import InfobipCallKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, InfobipCallHostDelegate {

    var window: UIWindow?
    private var callCenter: InfobipCallCenter!

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        // 1. Create the call center with any config/theme, and install it on the host window.
        //    To enable CallKit + background/locked/killed calls, set `pushConfigId` (from the
        //    Infobip portal) — leave it nil to use the foreground InfobipSimulator dev path.
        callCenter = InfobipCallCenter(config: InfobipCallConfig(
            pushConfigId: "1ce41cec-c13a-41b2-80dc-de54cf62d6bf",
            callKitDisplayName: "CallKit Example"
        ))
        callCenter.install(on: window)
        callCenter.hostDelegate = self

        // 2. Start listening for VoIP pushes at launch (before any token) so a call that launched
        //    the app from a killed state is delivered. No-op unless CallKit/pushConfigId is set.
        callCenter.client.prepareForIncomingCalls()

        // 2. Host UI.
        window.rootViewController = UINavigationController(rootViewController: HomeViewController(center: callCenter))
        window.makeKeyAndVisible()
        self.window = window
    }

    // MARK: - InfobipCallHostDelegate

    func callRequestsChat(peerName: String) {
        // Present your own messaging UI for `peerName`.
        print("[Example] open chat with \(peerName)")
    }
}

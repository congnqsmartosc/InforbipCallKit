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
        callCenter = InfobipCallCenter(config: InfobipCallConfig())
        callCenter.install(on: window)
        callCenter.hostDelegate = self

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

    func callDidFinish(withFeedbackRating rating: Int?, reasons: [String]) {
        print("[Example] feedback rating=\(String(describing: rating)) reasons=\(reasons)")
    }
}

import UIKit
import InfobipCallKit

/// Example host that uses the classic `UIApplicationDelegate`-only lifecycle — no SceneDelegate,
/// no `UIApplicationSceneManifest` in Info.plist. InfobipCallKit presents the call UI on its own
/// overlay window and resolves the active window scene automatically, so nothing scene-specific
/// is required here.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate, InfobipCallHostDelegate {

    var window: UIWindow?
    private var callCenter: InfobipCallCenter!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Create the call center and (optionally) hint it at the host window.
        //    Set `pushConfigId` (Infobip portal) to enable CallKit + background/locked/killed calls.
        callCenter = InfobipCallCenter(config: InfobipCallConfig(
            // pushConfigId: "your-infobip-push-config-id",
            callKitDisplayName: "CallKit Example"
        ))
        callCenter.hostDelegate = self
        // Start listening for VoIP pushes at launch (before any token) so a killed-app launch is
        // delivered. No-op unless CallKit/pushConfigId is set.
        callCenter.client.prepareForIncomingCalls()

        // 2. Classic AppDelegate window setup.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: HomeViewController(center: callCenter))
        window.makeKeyAndVisible()
        self.window = window

        callCenter.install(on: window)   // optional — a hint for which scene to attach the call UI to
        return true
    }

    // MARK: - InfobipCallHostDelegate

    func callRequestsChat(peerName: String) {
        print("[AppDelegateExample] open chat with \(peerName)")
    }
}

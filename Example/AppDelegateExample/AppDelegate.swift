import UIKit
import PushKit
import InfobipCallKit

/// Example host that uses the classic `UIApplicationDelegate`-only lifecycle — no SceneDelegate,
/// no `UIApplicationSceneManifest` in Info.plist. InfobipCallKit presents the call UI on its own
/// overlay window and resolves the active window scene automatically, so nothing scene-specific
/// is required here.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate, InfobipCallHostDelegate {

    var window: UIWindow?
    private var callCenter: InfobipCallCenter!

    /// The host app owns the VoIP push registry (CallKit / APNs path).
    private var voipRegistry: PKPushRegistry?

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

        // 2. Set up CallKit now that we've decided to use Infobip. Skip this (or call
        //    deactivateCallService()) for a GSM-only path so CallKit stays free for another SDK.
        callCenter.activateCallService()

        // 3. The HOST owns the VoIP push registry. Create it at launch (before any token) so a call
        //    that launched the app from a killed state is delivered.
        let registry = PKPushRegistry(queue: .main)
        registry.desiredPushTypes = [.voIP]
        registry.delegate = self
        voipRegistry = registry

        // 4. Classic AppDelegate window setup.
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

// MARK: - PKPushRegistryDelegate (host-owned VoIP registry)

extension AppDelegate: PKPushRegistryDelegate {

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        callCenter.client.enablePushNotifications(credentials: pushCredentials)
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard type == .voIP else { return }
        callCenter.client.disablePushNotifications()
    }

    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        // Hand the push to Infobip synchronously, THEN call completion().
        callCenter.client.handleIncomingPush(payload: payload)
        completion()
    }
}

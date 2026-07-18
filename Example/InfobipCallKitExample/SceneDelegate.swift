import UIKit
import PushKit
import InfobipCallKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, InfobipCallHostDelegate {

    var window: UIWindow?
    private var callCenter: InfobipCallCenter!

    /// The Infobip WebRTC push-configuration id. Here we pass it to Infobip **at runtime** (via
    /// `enablePushNotifications(credentials:pushConfigId:)`) instead of hardcoding it in
    /// `InfobipCallConfig` — e.g. a real app might fetch it from remote config per environment.
    private let pushConfigId = "1ce41cec-c13a-41b2-80dc-de54cf62d6bf"

    /// The host app owns the VoIP push registry (CallKit / APNs path). It gets the device token,
    /// hands it to Infobip via `enablePushNotifications(credentials:pushConfigId:)`, and hands each
    /// incoming VoIP push to Infobip via `handleIncomingPush(payload:)`.
    private var voipRegistry: PKPushRegistry?

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
        //    `enableCallKit: true` turns CallKit on without hardcoding pushConfigId here — the id is
        //    supplied at runtime in the push-registry delegate below.
        callCenter = InfobipCallCenter(config: InfobipCallConfig(
            callKitDisplayName: "CallKit Example",
            enableCallKit: true
        ))
        callCenter.install(on: window)
        callCenter.hostDelegate = self

        // 2. Set up CallKit now that we've decided to use Infobip. (A GSM-only build, or after a
        //    remote-config/login check, would skip this — or call deactivateCallService() — to leave
        //    CallKit free for another SDK.)
        callCenter.activateCallService()

        // 3. The HOST owns the VoIP push registry. Create it as early as possible so a call that
        //    launched the app from a killed state is delivered.
        let registry = PKPushRegistry(queue: .main)
        registry.desiredPushTypes = [.voIP]
        registry.delegate = self
        voipRegistry = registry

        // 4. Host UI.
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

// MARK: - PKPushRegistryDelegate (host-owned VoIP registry)

extension SceneDelegate: PKPushRegistryDelegate {

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        // Send the device token + the push-config id to Infobip so its server can send VoIP pushes.
        // Passing pushConfigId here (instead of in InfobipCallConfig) lets the host choose it at
        // runtime. Safe to call before or after registerSubscriber(...); Infobip binds once ready.
        callCenter.client.enablePushNotifications(credentials: pushCredentials, pushConfigId: pushConfigId)
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
        // IMPORTANT: hand the push to Infobip synchronously, THEN call completion(). Infobip reports
        // the incoming call to CallKit before this returns, so iOS won't kill a push-launched app.
        callCenter.client.handleIncomingPush(payload: payload)
        completion()
    }
}

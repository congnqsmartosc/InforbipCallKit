# InfobipCallKit (iOS)

A drop-in WebRTC calling experience for iOS, wrapping the **Infobip RTC SDK**. InfobipCallKit
ships the complete calling UI — incoming banner, in-call screen, ringtone/ringback, mute/speaker,
audio-route picker, post-call feedback, and "recipient unreachable" — and presents it all on its
own overlay window, so it never fights your app's navigation.

The public API mirrors the Android `InfobipCallClient` interface, so both platforms integrate the
same way. **Your app supplies the WebRTC token** (from your backend) — no Infobip API key ever
ships inside the framework.

## Requirements

- iOS 15.0+
- Swift 5.0+
- CocoaPods, with **`use_frameworks!`** (the Infobip RTC binary is a dynamic framework)

## Installation

InfobipCallKit is distributed as a CocoaPods pod.

```ruby
# Podfile
platform :ios, '15.0'
use_frameworks!            # REQUIRED

target 'YourApp' do
  pod 'InfobipCallKit', :git => 'https://your.repo/InfobipCallKit.git', :tag => '1.0.0'
  # For the optional RxSwift stream `rx_activeSession`:
  # pod 'InfobipCallKit', :git => '...', :tag => '1.0.0', :subspecs => ['Core', 'Rx']
end
```

> **Notes**
> - `use_frameworks!` is mandatory — the Infobip RTC pod vendors a dynamic Swift/WebRTC binary.
> - InfobipCallKit bundles WebRTC transitively via `InfobipRTC`. It is **incompatible with any
>   other WebRTC build** linked into the same app target.

### Info.plist

Add (the framework needs the mic and background audio during calls):

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone is used to make and receive calls.</string>
<key>UIBackgroundModes</key>
<array><string>audio</string></array>
```

## Initialize the SDK

Create one `InfobipCallCenter` and keep it alive for the app's lifetime. It presents the calling
UI on its own overlay window and resolves the active window scene automatically, so it works with
**either** app lifecycle. `install(on:)` is optional — a hint for which window scene to attach to.

**`UISceneDelegate`:**

```swift
import InfobipCallKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var callCenter: InfobipCallCenter!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = /* your root VC */
        window.makeKeyAndVisible()
        self.window = window

        callCenter = InfobipCallCenter(config: InfobipCallConfig())
        callCenter.install(on: window)     // optional scene hint
        callCenter.hostDelegate = self     // optional: chat / feedback hand-offs
    }
}
```

**`UIApplicationDelegate` only** (no SceneDelegate, no `UIApplicationSceneManifest`):

```swift
import InfobipCallKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var callCenter: InfobipCallCenter!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        callCenter = InfobipCallCenter(config: InfobipCallConfig())
        callCenter.hostDelegate = self

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = /* your root VC */
        window.makeKeyAndVisible()
        self.window = window

        callCenter.install(on: window)     // optional scene hint
        return true
    }
}
```

> The Infobip RTC SDK itself (PushKit incoming calls, `InfobipSimulator`, tokens, media) is
> independent of the scene lifecycle — both host styles are fully supported.

`InfobipCallConfig` lets you override the `customData` key names, set a real APNs VoIP
`pushConfigId`, and theme the UI:

```swift
InfobipCallConfig(
    pushConfigId: nil,                                     // nil = foreground InfobipSimulator mode
    customDataKeys: .init(displayName: "displayName", avatarURL: "avatarUrl"),
    theme: InfobipCallTheme(accent: .systemTeal),
    isLoggingEnabled: true                                 // DEBUG-only `[InfobipCallKit][…]` logs
)
```

`isLoggingEnabled` (default `true`) prints `[InfobipCallKit][…]` trace logs to help you debug the
calling flow. Logs are additionally compiled out of Release builds, so production apps never see
them regardless of the flag — set `false` to silence them in DEBUG too.

## Register the user

Obtain a WebRTC token from **your backend** (which calls Infobip
`POST /webrtc/1/token`), then register and start listening:

```swift
let token = try await MyBackend.fetchWebRTCToken(identity: "driver")
try await callCenter.client.registerSubscriber(
    identity: "driver",
    displayName: "Nguyễn Văn Nam",
    token: token,
    imageURL: "https://…/me.jpg"      // the subscriber's own avatar (optional)
)
try await callCenter.client.registerForIncomingCalls()

// on token refresh:  callCenter.client.updateToken(newToken)
// on logout:         callCenter.client.clearSubscriber()
```

The framework never mints tokens — your backend does. `pushConfigId` (on `InfobipCallConfig`)
stays host-provided too.

## Make / receive calls

```swift
// The registered subscriber's displayName + imageURL are auto-forwarded to the callee, so a
// plain call already shows the right caller on their incoming screen:
try await callCenter.client.startOutgoingCall(destinationIdentity: "customer")

// …or pass customData explicitly to override / add fields (host values win over auto-forwarded):
try await callCenter.client.startOutgoingCall(
    destinationIdentity: "customer",
    customData: ["displayName": "Nguyễn Văn Nam", "avatarUrl": "https://…/a.jpg"]
)
```

Incoming calls are delivered automatically after `registerForIncomingCalls()` — the framework
presents the ringing banner and the full call screen; the user accepts/declines in-UI.

Programmatic control (optional — the built-in UI already wires these to buttons):

```swift
try await callCenter.client.acceptIncomingCall()
try await callCenter.client.declineIncomingCall()
try await callCenter.client.hangUp()
try await callCenter.client.setMuted(true)
try await callCenter.client.setSpeakerOn(true)
```

## Observe call state

`activeSession` is the current `CallSession?` (Android `StateFlow<CallSession?>`). Observe it three ways:

```swift
// 1. current value
let session = callCenter.client.activeSession

// 2. delegate
callCenter.client.delegate = self
func callClient(_ client: InfobipCallClient, didUpdate session: CallSession?) { … }

// 3. closure
let token = callCenter.client.observeSession { session in … }   // retain `token`; token.cancel() to stop

// 4. RxSwift (requires the `Rx` subspec)
callCenter.client.rx_activeSession
    .subscribe(onNext: { session in … })
    .disposed(by: bag)
```

## Observe call events

Alongside the `activeSession` state, the SDK emits discrete **`InfobipCallEvent`**s for every
signal it receives — call start/end (with a structured end reason), connection/signal quality, and
mute / speaker / audio-route changes. Delivered the same three ways as state:

```swift
// delegate (optional method — default no-op)
func callClient(_ client: InfobipCallClient, didReceive event: InfobipCallEvent) {
    switch event {
    case .started(let session):            // outgoing placed / incoming received
    case .ringing, .connecting, .established:
    case .ended(let reason):               // reason.name e.g. "NORMAL_HANGUP" / "NO_ANSWER", .code, .message, .isError
    case .networkQualityChanged(let q):    // .bad … .excellent
    case .muteChanged(let m):
    case .speakerChanged(let on):
    case .audioRouteChanged(let name):
    }
}

// closure
let token = callCenter.client.observeEvents { event in … }   // retain `token`

// RxSwift (requires the `Rx` subspec)
callCenter.client.rx_callEvents.subscribe(onNext: { event in … }).disposed(by: bag)
```

`CallSession` also carries the latest `networkQuality`, and (when `status == .ended`) the
`endReason`, for consumers that only observe state.

## Background, locked & killed-app calls (CallKit + VoIP push)

By default (`pushConfigId == nil`) the framework receives incoming calls only while the app is
**foregrounded** (via the Infobip `InfobipSimulator` socket) and shows its own in-app banner — ideal
for development. To ring when the app is **backgrounded, locked, or killed**, enable real APNs VoIP
push, and the framework automatically drives **CallKit** (system incoming/outgoing UI) for you.

**1. Provision (once):**
- Apple Developer → App ID with **Push Notifications**; create a **VoIP Services Certificate**
  (`.p12`).
- Infobip → create a WebRTC push configuration with that `.p12`; the response `id` is your
  **`pushConfigId`**.

**2. Host capabilities:** add the **Push Notifications** capability (`aps-environment` entitlement)
and set `UIBackgroundModes` to include **`voip`** (plus `audio`). See `Example/*/*.entitlements` and
`Example/project.yml`.

**3. Configure & boot early:**
```swift
// In application(_:didFinishLaunchingWithOptions:) / scene(_:willConnectTo:)
callCenter = InfobipCallCenter(config: InfobipCallConfig(
    pushConfigId: "your-infobip-push-config-id",   // turns CallKit on
    callKitDisplayName: "My App",                  // shown on the system call UI
    ringtoneSound: "ring.caf"                       // optional
))
callCenter.client.prepareForIncomingCalls()        // MUST be called synchronously at launch so a
                                                    // killed-app VoIP push is caught
```

**4. Keep the binding alive:** persist the logged-in identity and, on every launch, fetch a fresh
token and call `registerSubscriber(...)` + `registerForIncomingCalls()`. A **killed-app incoming
call needs no token** (the SDK handles the push payload directly); the token is only needed to
enable push and to place outgoing calls.

When CallKit is on, incoming calls ring through the **system UI** (even in the foreground — no custom
banner), the user answers/declines there, and the framework presents its in-call screen once the app
is active. Outgoing calls show the system green pill / lock-screen controls / Recents. The
`activeSession` state and `InfobipCallEvent` stream behave the same in both modes.

> The framework deliberately does **not** forward CallKit's `didActivate` audio session — the Infobip
> RTC SDK owns and configures `AVAudioSession` itself.

## Host hand-offs

Actions the UI surfaces but your app owns, via `InfobipCallHostDelegate`:

```swift
func callRequestsChat(peerName: String)                        // "Message" button
func callDidFinish(withFeedbackRating rating: Int?, reasons: [String])  // post-call feedback
```

## Example app

`Example/` is a runnable integration reference.

```bash
cd Example
xcodegen generate      # generates InfobipCallKitExample.xcodeproj
pod install            # creates InfobipCallKitExample.xcworkspace
open InfobipCallKitExample.xcworkspace
```

Two schemes demonstrate both host lifecycles against the same shared UI:
- **InfobipCallKitExample** — `UISceneDelegate`-based
- **InfobipCallKitExampleAppDelegate** — classic `UIApplicationDelegate`-only (no scene manifest)

The demo mints a token client-side for convenience (production apps must do this on a backend).
Provide the Infobip App key at runtime — it is **not** committed:

- Scheme ▸ Run ▸ Arguments ▸ Environment Variables: `INFOBIP_API_KEY = <your key>`, **or**
- add a git-ignored `Secrets.plist` to the app target with a string key `INFOBIP_API_KEY`.

Run two devices, register each as a different identity (`driver` / `customer`), and place a call.

> Incoming calls, PushKit / `InfobipSimulator`, and mic capture behave differently on the
> simulator — test on real devices.

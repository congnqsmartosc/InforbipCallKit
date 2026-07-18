# Changelog

All notable changes to **InfobipCallKit** are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## [1.3.1]

### Added
- **Callee display info on outgoing calls.** `startOutgoingCall` now takes optional `displayName` /
  `imageURL` for the **callee**, so the caller's own in-call screen and the CallKit UI show the
  callee's friendly name/avatar instead of the raw identity:
  `startOutgoingCall(destinationIdentity:displayName:imageURL:customData:)` (older overloads kept).
- **More observable events** on the `InfobipCallEvent` stream:
  - Network reconnection — `.reconnecting`, `.reconnected`, `.remoteDisconnected`, `.remoteReconnected`.
  - `CallEndReason.category` — a semantic classification of the SDK end code
    (`.normal` / `.noAnswer` / `.busy` / `.declined` / `.cancelled` / `.unavailable` /
    `.deviceError` / `.mediaError` / `.unauthorized` / `.error`), so hosts can detect "callee
    unavailable/offline" etc. without hard-coding Infobip numbers.

### Changed
- Counterpart name resolution now prefers the app-provided display name (customData) over the SDK
  endpoint's raw identifier.

## [Unreleased]

### Added — host-configurable call UI
- **`InfobipCallAppearance`** (on `InfobipCallConfig.appearance`): full visual config — colors
  (incl. text/surface/gradient), fonts, metrics, an `InfobipCallIcons` set, and avatar. Supersedes
  the 4-color `InfobipCallTheme`, which still works and maps into it. Colors are dynamic-capable
  (light/dark).
- **`InfobipCallStrings`** (on `InfobipCallConfig.strings`): every user-facing string with English
  defaults — replacing the previously hardcoded (mostly Vietnamese) literals across all call screens.
- **`InfobipCallUIProviding`** (on `InfobipCallCenter.uiProvider`): supply your own view controllers
  for any call screen — `makeInCallScreen` / `makeIncomingBanner` / `makeAudioRouteSheet` /
  `makeUnreachableScreen` / `makeKeypad`. Each returns `nil` (default) for the built-in screen, or a
  `UIViewController` driven by a per-scene context (`InCallContext`, `IncomingCallContext`,
  `AudioRouteContext`, `UnreachableContext`, `KeypadContext`). The pod keeps owning call state,
  CallKit, ringtone, and navigation/teardown.
- **Public audio-route control:** `AudioRoute` type, `client.selectAudioRoute(id:)`, and
  `CallSession.audioRoutes` / `activeAudioRoute` (for custom audio pickers). `client.retryLastCall()`
  is now public.
- **Runtime appearance/strings switching:** `InfobipCallCenter.updateAppearance(_:)` and
  `updateStrings(_:)` swap the built-in UI's look/text at runtime (applies to the next call screen).
- **Runtime push-config id:** `client.enablePushNotifications(credentials:pushConfigId:)` lets the
  host supply the Infobip WebRTC push-config id at enable time (e.g. from remote config), overriding
  `InfobipCallConfig.pushConfigId`. The old `enablePushNotifications(credentials:)` still works.

### Changed
- **Post-call "unreachable" screen** now shows only **Try again** (promoted to the primary button);
  the **Send a message** option was removed (`UnreachableContext.sendMessage` removed too).

### Fixed
- **Dark mode:** the in-call/unreachable/keypad background gradient no longer stays white in dark
  mode; gradient colors are resolved against the trait collection and re-resolved on Light/Dark change.

### Example
- The setup screen adds a **Theme** picker (Teal / Indigo, incl. fonts) and a **Language** picker
  (English / Tiếng Việt) driving `updateAppearance` / `updateStrings`, and passes `pushConfigId` at
  runtime via `enablePushNotifications(credentials:pushConfigId:)`.

### Notes
- Adding public enum cases / config fields is additive; existing hosts (incl. `config.theme`-only)
  compile and look unchanged. Per-region "slot" injection into the built-in in-call screen is not
  included — compose a full custom screen instead.

## [1.3.0]

### Added
- **`activateCallService()` / `deactivateCallService()`** on `InfobipCallCenter` (and
  `InfobipCallClient`). CallKit (`CXProvider`) is now created **lazily** — you can init the center and
  the host `PKPushRegistry` early, but CallKit isn't set up until `activateCallService()`.
  `deactivateCallService()` ends any in-flight calls and releases the `CXProvider` so another calling
  SDK (e.g. GSM) can own CallKit, or for logout.

### Changed
- CallKit calls are kept out of the system call history — `CXProviderConfiguration.includesCallsInRecents = false`.

### Migration (from 1.2.0)
- CallKit is no longer created automatically. Call **`callCenter.activateCallService()`** once at
  launch (before forwarding VoIP pushes) when your app uses the Infobip calling path. See the README
  "Background, locked & killed-app calls" section, step 4.

## [1.2.0]

### Changed (breaking — CallKit / VoIP push path)
- **The host app now owns the `PKPushRegistry`.** The pod no longer creates or manages a VoIP push
  registry internally. The host creates the registry, receives the device token, and forwards the
  PushKit callbacks to the pod. This gives the host full control of the push lifecycle. New API:
  - `client.enablePushNotifications(credentials:)` — call from `pushRegistry(_:didUpdate:for:)` to
    send the VoIP device token to Infobip.
  - `client.handleIncomingPush(payload:)` — call **synchronously** from
    `pushRegistry(_:didReceiveIncomingPushWith:for:completion:)` (before `completion()`) to hand an
    incoming VoIP push to Infobip; it reports the call to CallKit and starts the WebRTC call.
  - `client.disablePushNotifications()` — call from `pushRegistry(_:didInvalidatePushTokenFor:)`.
- **Removed `client.prepareForIncomingCalls()`** — the host owns registry creation now, so it is no
  longer needed. `registerForIncomingCalls()` remains but is only meaningful on the foreground
  `InfobipSimulator` dev path (`pushConfigId == nil`); it is a no-op on the CallKit/APNs path.

### Migration
- Move the `PKPushRegistry` creation into your `AppDelegate`/`SceneDelegate`, conform it to
  `PKPushRegistryDelegate`, and forward the three callbacks as shown in the README and in
  `Example/*/*.swift`. Delete any `prepareForIncomingCalls()` call.

## [1.1.2]

### Removed
- Post-call **feedback / rating screen** — a call now ends straight to teardown.
- `InfobipCallHostDelegate.callDidFinish(withFeedbackRating:reasons:)` (the feedback callback) is
  removed. `callRequestsChat(peerName:)` is unchanged.

## [1.1.1] 

### Changed
- In-call screen now shows **Speaker** and **Mute** only — the **Message** button was removed.

## [1.1.0] 

### Added
- **Call event stream.** A new `InfobipCallEvent` is delivered via the delegate
  (`callClient(_:didReceive:)`), a closure (`observeEvents(_:)`), and — with the `Rx` subspec —
  `rx_callEvents`. Events cover call started / ringing / connecting / established / ended, connection
  (signal) quality, and mute / speaker / audio-route changes.
- **Structured end reason.** `ended` events (and `CallSession.endReason`) carry `CallEndReason`
  (`code`, `name`, `message`, `isError`) mapped from the SDK — e.g. `NORMAL_HANGUP`, `NO_ANSWER`.
- **Network quality.** `InfobipNetworkQuality` (`bad`…`excellent`) surfaced via events and
  `CallSession.networkQuality`.
- **Subscriber image + auto-forward.** `registerSubscriber(identity:displayName:token:imageURL:)`
  stores the subscriber's own avatar and auto-forwards the caller's name + image into outgoing-call
  `customData`, so `startOutgoingCall(destinationIdentity:)` needs no hand-built `customData`.
- **Debug logging.** `[InfobipCallKit][…]` trace logs at public entry points and events, gated by
  `#if DEBUG` **and** `InfobipCallConfig.isLoggingEnabled` (default on; compiled out of Release builds).
- **Background / locked / killed-app calls (CallKit + real VoIP push).** Set
  `InfobipCallConfig.pushConfigId` to enable CallKit — incoming calls ring through the system UI in
  any app state and outgoing calls show the system call UI / Recents. New config knobs:
  `callKitDisplayName`, `callKitIconTemplateImageData`, `ringtoneSound`, `enableCallKit`. New
  `client.prepareForIncomingCalls()` to start the VoIP registry at launch (call it synchronously in
  `didFinishLaunching`). The podspec now links the `CallKit` framework.

### Notes
- Backward compatible: the original 3-argument `registerSubscriber(identity:displayName:token:)` is
  kept as an overload, and the new delegate event method has a default no-op implementation.
- With `pushConfigId == nil` the foreground `InfobipSimulator` dev path is unchanged (custom banner +
  in-app ringtone, no CallKit).

## [1.0.0]

### Added
- Initial release. A drop-in WebRTC calling experience wrapping the Infobip RTC iOS SDK:
  incoming/outgoing call screens, ringtone/ringback, in-call controls (mute, speaker, audio route),
  and post-call feedback, presented on the framework's own overlay window.
- Host-provided token model via `registerSubscriber(identity:displayName:token:)` — the framework
  never mints tokens.
- `activeSession` state observable three ways: delegate, closure (`observeSession`), and an optional
  `Rx` subspec (`rx_activeSession`). Public API mirrors the Android `InfobipCallClient`.
- Foreground incoming calls via the SDK's `InfobipSimulator`.


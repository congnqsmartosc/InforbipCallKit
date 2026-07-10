# Changelog

All notable changes to **InfobipCallKit** are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## [1.1.1] - 2026-07-10

### Changed
- In-call screen now shows **Speaker** and **Mute** only — the **Message** button was removed.

## [1.1.0] - 2026-07-09

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

## [1.0.0] - 2026-07-08

### Added
- Initial release. A drop-in WebRTC calling experience wrapping the Infobip RTC iOS SDK:
  incoming/outgoing call screens, ringtone/ringback, in-call controls (mute, speaker, audio route),
  and post-call feedback, presented on the framework's own overlay window.
- Host-provided token model via `registerSubscriber(identity:displayName:token:)` — the framework
  never mints tokens.
- `activeSession` state observable three ways: delegate, closure (`observeSession`), and an optional
  `Rx` subspec (`rx_activeSession`). Public API mirrors the Android `InfobipCallClient`.
- Foreground incoming calls via the SDK's `InfobipSimulator`.

[1.1.1]: https://github.com/congnqsmartosc/InforbipCallKit/releases/tag/1.1.1
[1.1.0]: https://github.com/congnqsmartosc/InforbipCallKit/releases/tag/1.1.0
[1.0.0]: https://github.com/congnqsmartosc/InforbipCallKit/releases/tag/1.0.0

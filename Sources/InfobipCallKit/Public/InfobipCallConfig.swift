import UIKit

/// Configuration passed by the host app when creating an ``InfobipCallCenter``.
///
/// Unlike the POC, the framework never embeds an Infobip API key and never mints
/// WebRTC tokens itself — the host supplies a token via ``InfobipCallClient/registerSubscriber(identity:displayName:token:)``.
/// This type only carries integration knobs: how caller info travels in `customData`,
/// the optional APNs VoIP push config, and theming.
public struct InfobipCallConfig {

    /// Keys used inside a call's `customData` to carry the caller's display info to the callee.
    /// Must match what the counterpart platform (e.g. Android) sends.
    public struct CustomDataKeys: Equatable {
        public var displayName: String
        public var avatarURL: String

        public init(displayName: String = "displayName", avatarURL: String = "avatarUrl") {
            self.displayName = displayName
            self.avatarURL = avatarURL
        }
    }

    /// Infobip push configuration id (from the Infobip portal) for real APNs VoIP pushes.
    /// Leave `nil` to use the SDK's active-connection mode (`InfobipSimulator`), which
    /// receives calls while the app is in the foreground — matching the POC default.
    ///
    /// When set, the framework enables **CallKit** (system incoming/outgoing call UI + VoIP push),
    /// so calls ring when the app is backgrounded, locked, or killed. See ``enableCallKit``.
    public var pushConfigId: String?

    /// CallKit provider display name (shown on the system call UI / lock screen / Recents).
    public var callKitDisplayName: String

    /// Optional CallKit provider icon (a template PNG's raw data), shown next to the call UI.
    public var callKitIconTemplateImageData: Data?

    /// Ringtone file name (must be bundled) CallKit plays for incoming calls. Defaults to the
    /// framework's `"ring.caf"`.
    public var ringtoneSound: String?

    /// Overrides whether CallKit is used. `nil` (default) derives it from `pushConfigId != nil` —
    /// i.e. CallKit is on exactly for the real APNs VoIP path, and off for the foreground
    /// `InfobipSimulator` dev path. Set explicitly only to force one or the other.
    public var enableCallKit: Bool?

    /// Resolved CallKit switch: explicit `enableCallKit`, else `pushConfigId != nil`.
    public var isCallKitEnabled: Bool { enableCallKit ?? (pushConfigId != nil) }

    /// `customData` key names used to pass caller display info through a call.
    public var customDataKeys: CustomDataKeys

    /// Visual theme for the built-in call UI.
    public var theme: InfobipCallTheme

    /// When `true` (default), the framework prints `[InfobipCallKit][…]` debug logs to help hosts
    /// trace the calling flow. Logs are additionally compiled out of Release builds of the pod, so
    /// this flag only affects DEBUG builds. Set `false` to silence logs even in DEBUG.
    public var isLoggingEnabled: Bool

    public init(
        pushConfigId: String? = nil,
        customDataKeys: CustomDataKeys = .init(),
        theme: InfobipCallTheme = .default,
        isLoggingEnabled: Bool = true,
        callKitDisplayName: String = "Call",
        callKitIconTemplateImageData: Data? = nil,
        ringtoneSound: String? = "ring.caf",
        enableCallKit: Bool? = nil
    ) {
        self.pushConfigId = pushConfigId
        self.customDataKeys = customDataKeys
        self.theme = theme
        self.isLoggingEnabled = isLoggingEnabled
        self.callKitDisplayName = callKitDisplayName
        self.callKitIconTemplateImageData = callKitIconTemplateImageData
        self.ringtoneSound = ringtoneSound
        self.enableCallKit = enableCallKit
    }
}

/// Colors used by the built-in calling screens. Defaults match the original prototype;
/// override any value to match the host app's brand.
public struct InfobipCallTheme {
    public var accent: UIColor
    public var accept: UIColor
    public var decline: UIColor
    public var controlOn: UIColor

    public init(
        accent: UIColor = UIColor(red: 0.0, green: 0.74, blue: 0.79, alpha: 1.0),
        accept: UIColor = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0),
        decline: UIColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0),
        controlOn: UIColor = UIColor(red: 0.0, green: 0.74, blue: 0.79, alpha: 0.15)
    ) {
        self.accent = accent
        self.accept = accept
        self.decline = decline
        self.controlOn = controlOn
    }

    public static let `default` = InfobipCallTheme()
}

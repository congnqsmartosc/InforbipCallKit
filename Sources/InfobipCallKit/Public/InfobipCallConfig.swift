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
    public var pushConfigId: String?

    /// `customData` key names used to pass caller display info through a call.
    public var customDataKeys: CustomDataKeys

    /// Visual theme for the built-in call UI.
    public var theme: InfobipCallTheme

    public init(
        pushConfigId: String? = nil,
        customDataKeys: CustomDataKeys = .init(),
        theme: InfobipCallTheme = .default
    ) {
        self.pushConfigId = pushConfigId
        self.customDataKeys = customDataKeys
        self.theme = theme
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

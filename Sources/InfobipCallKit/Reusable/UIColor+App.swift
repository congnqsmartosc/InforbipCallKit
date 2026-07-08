import UIKit

/// Runtime theme holder. `InfobipCallCenter` sets `current` from `InfobipCallConfig.theme`
/// before any call screen appears, so the palette below reflects the host's branding.
/// Falls back to the prototype defaults when unset.
enum CallTheme {
    static var current: InfobipCallTheme = .default
}

/// Central color palette for the calling screens — sourced from the active ``InfobipCallTheme``.
/// System colors are used for surfaces/text so they adapt to Light/Dark automatically.
extension UIColor {

    /// Primary accent (teal by default).
    static var appAccent: UIColor { CallTheme.current.accent }

    /// Card / sheet surface.
    static let appSurface = UIColor.systemBackground

    /// Primary / secondary text.
    static let appTextPrimary = UIColor.label
    static let appTextSecondary = UIColor.secondaryLabel

    /// Accept (green) / decline-end (red) buttons.
    static var appAccept: UIColor { CallTheme.current.accept }
    static var appDecline: UIColor { CallTheme.current.decline }

    /// Light background for an active control (Speaker/Mute…).
    static var appControlOn: UIColor { CallTheme.current.controlOn }
}

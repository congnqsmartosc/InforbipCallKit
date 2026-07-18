import UIKit

/// Runtime style holders. `InfobipCallCenter` sets these from `InfobipCallConfig` before any call
/// screen appears, so the palette/fonts/strings below reflect the host's branding. They fall back to
/// the prototype defaults when unset.
enum CallAppearance {
    static var current: InfobipCallAppearance = .default
}

enum CallStrings {
    static var current: InfobipCallStrings = .default
}

/// Back-compat holder for the color-only ``InfobipCallTheme``. New code reads ``CallAppearance``.
enum CallTheme {
    static var current: InfobipCallTheme = .default
}

/// Central color palette for the calling screens — sourced from the active ``InfobipCallAppearance``.
extension UIColor {

    /// Primary accent (teal by default).
    static var appAccent: UIColor { CallAppearance.current.accent }

    /// Card / sheet surface.
    static var appSurface: UIColor { CallAppearance.current.surface }

    /// Primary / secondary text.
    static var appTextPrimary: UIColor { CallAppearance.current.textPrimary }
    static var appTextSecondary: UIColor { CallAppearance.current.textSecondary }

    /// Accept (green) / decline-end (red) buttons.
    static var appAccept: UIColor { CallAppearance.current.accept }
    static var appDecline: UIColor { CallAppearance.current.decline }

    /// Light background for an active control (Speaker/Mute…).
    static var appControlOn: UIColor { CallAppearance.current.controlOn }

    /// Background for an inactive control.
    static var appControlOff: UIColor { CallAppearance.current.controlOffBackground }
}

extension CAGradientLayer {
    /// Apply the appearance's background gradient, resolving dynamic colors against `traits`.
    /// `CAGradientLayer` holds static `cgColor`s, so callers must re-invoke this on
    /// `traitCollectionDidChange` for Light/Dark to track. Clears the gradient if disabled.
    func applyCallBackground(for traits: UITraitCollection) {
        let a = CallAppearance.current
        guard let top = a.gradientTop, let bottom = a.gradientBottom else {
            colors = nil
            return
        }
        colors = [top.resolvedColor(with: traits).cgColor, bottom.resolvedColor(with: traits).cgColor]
    }
}

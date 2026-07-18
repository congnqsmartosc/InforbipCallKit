import UIKit

/// Full visual configuration for the built-in call screens — colors, fonts, metrics, icons, and the
/// avatar. Supersedes the color-only ``InfobipCallTheme`` (which still works and maps into this).
///
/// All colors are plain `UIColor`, passed through **unflattened**, so you can supply dynamic
/// light/dark colors (`UIColor { $0.userInterfaceStyle == .dark ? … : … }` or asset-catalog colors)
/// and the UI — including the gradient — tracks the system appearance.
public struct InfobipCallAppearance {

    // MARK: Colors
    /// Primary brand accent (active controls, highlights).
    public var accent: UIColor
    /// Accept / answer button.
    public var accept: UIColor
    /// Decline / end button.
    public var decline: UIColor
    /// Background tint of an active control (Speaker/Mute when on).
    public var controlOn: UIColor
    /// Background of an inactive control.
    public var controlOffBackground: UIColor
    /// Primary text.
    public var textPrimary: UIColor
    /// Secondary text (status line, captions).
    public var textSecondary: UIColor
    /// Card / sheet surface.
    public var surface: UIColor
    /// Top of the full-screen background gradient. `nil` (with `gradientBottom == nil`) disables it.
    public var gradientTop: UIColor?
    /// Bottom of the full-screen background gradient.
    public var gradientBottom: UIColor?

    // MARK: Fonts
    public var titleFont: UIFont
    public var nameFont: UIFont
    public var statusFont: UIFont
    public var captionFont: UIFont
    public var buttonFont: UIFont

    // MARK: Metrics
    public var avatarSize: CGFloat
    /// Avatar corner radius; `nil` → a circle (`avatarSize / 2`).
    public var avatarCornerRadius: CGFloat?
    public var actionButtonDiameter: CGFloat
    public var controlIconDiameter: CGFloat
    public var controlSpacing: CGFloat

    // MARK: Icons + avatar
    public var icons: InfobipCallIcons
    public var avatarPlaceholder: UIImage?
    public var avatarPlaceholderTint: UIColor

    public init(
        accent: UIColor = InfobipCallAppearance.defaultAccent,
        accept: UIColor = InfobipCallAppearance.defaultAccept,
        decline: UIColor = InfobipCallAppearance.defaultDecline,
        controlOn: UIColor = InfobipCallAppearance.defaultControlOn,
        controlOffBackground: UIColor = .secondarySystemBackground,
        textPrimary: UIColor = .label,
        textSecondary: UIColor = .secondaryLabel,
        surface: UIColor = .systemBackground,
        gradientTop: UIColor? = .systemBackground,
        gradientBottom: UIColor? = InfobipCallAppearance.defaultAccent.withAlphaComponent(0.12),
        titleFont: UIFont = .systemFont(ofSize: 17, weight: .semibold),
        nameFont: UIFont = .systemFont(ofSize: 22, weight: .semibold),
        statusFont: UIFont = .systemFont(ofSize: 15, weight: .regular),
        captionFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        buttonFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
        avatarSize: CGFloat = 120,
        avatarCornerRadius: CGFloat? = nil,
        actionButtonDiameter: CGFloat = 68,
        controlIconDiameter: CGFloat = 54,
        controlSpacing: CGFloat = 72,
        icons: InfobipCallIcons = InfobipCallIcons(),
        avatarPlaceholder: UIImage? = UIImage(systemName: "person.crop.circle.fill"),
        avatarPlaceholderTint: UIColor = .systemGray3
    ) {
        self.accent = accent
        self.accept = accept
        self.decline = decline
        self.controlOn = controlOn
        self.controlOffBackground = controlOffBackground
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.surface = surface
        self.gradientTop = gradientTop
        self.gradientBottom = gradientBottom
        self.titleFont = titleFont
        self.nameFont = nameFont
        self.statusFont = statusFont
        self.captionFont = captionFont
        self.buttonFont = buttonFont
        self.avatarSize = avatarSize
        self.avatarCornerRadius = avatarCornerRadius
        self.actionButtonDiameter = actionButtonDiameter
        self.controlIconDiameter = controlIconDiameter
        self.controlSpacing = controlSpacing
        self.icons = icons
        self.avatarPlaceholder = avatarPlaceholder
        self.avatarPlaceholderTint = avatarPlaceholderTint
    }

    /// Effective avatar corner radius (circle when unset).
    public var resolvedAvatarCornerRadius: CGFloat { avatarCornerRadius ?? avatarSize / 2 }

    /// Back-compat: build an appearance from the color-only ``InfobipCallTheme``.
    public init(theme: InfobipCallTheme) {
        self.init(accent: theme.accent, accept: theme.accept, decline: theme.decline, controlOn: theme.controlOn,
                  gradientBottom: theme.accent.withAlphaComponent(0.12))
    }

    public static let `default` = InfobipCallAppearance()

    // Prototype defaults (same in light/dark; override with dynamic colors if desired).
    public static let defaultAccent = UIColor(red: 0.0, green: 0.74, blue: 0.79, alpha: 1.0)
    public static let defaultAccept = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0)
    public static let defaultDecline = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0)
    public static let defaultControlOn = UIColor(red: 0.0, green: 0.74, blue: 0.79, alpha: 0.15)
}

/// The icon set used by the built-in call screens. Each defaults to an SF Symbol; override with your
/// own images (rendered as templates / tinted unless the image is `.alwaysOriginal`).
public struct InfobipCallIcons {
    public var accept: UIImage?
    public var decline: UIImage?
    public var hangup: UIImage?
    public var mute: UIImage?
    public var unmute: UIImage?
    public var speaker: UIImage?
    public var bluetooth: UIImage?
    public var headphones: UIImage?
    public var audioGeneric: UIImage?
    public var keypadHide: UIImage?

    public init(
        accept: UIImage? = UIImage(systemName: "phone.fill"),
        decline: UIImage? = UIImage(systemName: "xmark"),
        hangup: UIImage? = UIImage(systemName: "phone.down.fill"),
        mute: UIImage? = UIImage(systemName: "mic.fill"),
        unmute: UIImage? = UIImage(systemName: "mic.slash.fill"),
        speaker: UIImage? = UIImage(systemName: "speaker.wave.2.fill"),
        bluetooth: UIImage? = UIImage(systemName: "airpods"),
        headphones: UIImage? = UIImage(systemName: "headphones"),
        audioGeneric: UIImage? = UIImage(systemName: "speaker.wave.2"),
        keypadHide: UIImage? = UIImage(systemName: "chevron.down")
    ) {
        self.accept = accept
        self.decline = decline
        self.hangup = hangup
        self.mute = mute
        self.unmute = unmute
        self.speaker = speaker
        self.bluetooth = bluetooth
        self.headphones = headphones
        self.audioGeneric = audioGeneric
        self.keypadHide = keypadHide
    }
}

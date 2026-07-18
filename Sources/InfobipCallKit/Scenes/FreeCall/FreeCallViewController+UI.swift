import UIKit
import SnapKit

/// Phần dựng giao diện của màn Free call — tách khỏi VC để VC chỉ còn lifecycle + binding.
extension FreeCallViewController {

    func setupBackground() {
        view.backgroundColor = .appSurface
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        applyGradientColors()
    }

    /// Resolve the appearance's gradient colors against the current trait collection. `CAGradientLayer`
    /// holds `cgColor`s that don't auto-update, so the VC re-calls this on `traitCollectionDidChange`.
    func applyGradientColors() {
        gradientLayer.applyCallBackground(for: view.traitCollection)
    }

    func setupUI() {
        let appearance = CallAppearance.current
        let strings = CallStrings.current

        titleLabel.text = strings.callTitle
        titleLabel.font = appearance.titleFont
        titleLabel.textColor = .appTextPrimary
        titleLabel.textAlignment = .center

        subtitleLabel.font = appearance.statusFont
        subtitleLabel.textColor = .appTextSecondary
        subtitleLabel.textAlignment = .center

        avatarView.image = appearance.avatarPlaceholder
        avatarView.tintColor = appearance.avatarPlaceholderTint
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = appearance.resolvedAvatarCornerRadius

        nameLabel.font = appearance.nameFont
        nameLabel.textColor = .appTextPrimary
        nameLabel.textAlignment = .center

        let controlStack = UIStackView(arrangedSubviews: [speakerControl, muteControl])
        controlStack.axis = .horizontal
        controlStack.distribution = .fill
        controlStack.alignment = .top
        controlStack.spacing = appearance.controlSpacing

        speakerControl.configure(icon: appearance.icons.speaker, caption: strings.speaker)
        muteControl.configureToggle(
            offIcon: appearance.icons.mute,
            onIcon: appearance.icons.unmute,
            offCaption: strings.mute,
            onCaption: strings.unmute
        )

        declineButton.configure(icon: appearance.icons.decline, background: .appDecline, pointSize: 26)
        acceptButton.configure(icon: appearance.icons.accept, background: .appAccept, pointSize: 26)

        actionStack.axis = .horizontal
        actionStack.alignment = .center
        actionStack.spacing = appearance.controlSpacing
        actionStack.addArrangedSubview(declineButton)
        actionStack.addArrangedSubview(acceptButton)

        [titleLabel, subtitleLabel, avatarView, nameLabel, controlStack, actionStack].forEach {
            view.addSubview($0)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.centerX.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(44)
            make.centerX.equalToSuperview()
        }
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(appearance.avatarSize)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        controlStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(actionStack.snp.top).offset(-44)
        }
        actionStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
    }
}

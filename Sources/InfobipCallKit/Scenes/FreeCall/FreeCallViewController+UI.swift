import UIKit
import SnapKit

/// Phần dựng giao diện của màn Free call — tách khỏi VC để VC chỉ còn lifecycle + binding.
extension FreeCallViewController {

    func setupBackground() {
        view.backgroundColor = .systemBackground
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.appAccent.withAlphaComponent(0.12).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupUI() {
        titleLabel.text = "Free call"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .appTextPrimary
        titleLabel.textAlignment = .center

        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .appTextSecondary
        subtitleLabel.textAlignment = .center

        avatarView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarView.tintColor = .systemGray3
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 60

        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .appTextPrimary
        nameLabel.textAlignment = .center

        let controlStack = UIStackView(arrangedSubviews: [speakerControl, muteControl])
        controlStack.axis = .horizontal
        controlStack.distribution = .fill
        controlStack.alignment = .top
        controlStack.spacing = 72

        speakerControl.configure(icon: UIImage(systemName: "speaker.wave.2.fill"), caption: "Speaker")
        muteControl.configureToggle(
            offIcon: UIImage(systemName: "mic.fill"),
            onIcon: UIImage(systemName: "mic.slash.fill"),
            offCaption: "Mute",
            onCaption: "Unmute"
        )

        declineButton.configure(icon: UIImage(systemName: "xmark"), background: .appDecline, pointSize: 26)
        acceptButton.configure(icon: UIImage(systemName: "phone.fill"), background: .appAccept, pointSize: 26)

        actionStack.axis = .horizontal
        actionStack.alignment = .center
        actionStack.spacing = 72
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
            make.size.equalTo(120)
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

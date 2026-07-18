import UIKit
import SnapKit
import XCoordinator

/// Màn kết quả khi gọi đi không thành công (tài xế từ chối / không nhận được).
/// Theo prototype: "The recipient refused call" + "Traveling on the road…" + Try again / Send a message / Dial.
final class CallUnreachableViewController: UIViewController {

    var router: UnownedRouter<CallRoute>?

    private let callerName: String
    private let destinationIdentity: String
    private let gradientLayer = CAGradientLayer()

    init(callerName: String, destinationIdentity: String) {
        self.callerName = callerName
        self.destinationIdentity = destinationIdentity
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) chưa hỗ trợ")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            gradientLayer.applyCallBackground(for: view.traitCollection)
        }
    }

    private func setupBackground() {
        view.backgroundColor = .appSurface
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.applyCallBackground(for: view.traitCollection)
    }

    private func setupUI() {
        let closeButton = CircleIconButton(diameter: 36)
        closeButton.configure(
            icon: UIImage(systemName: "xmark"),
            background: .secondarySystemBackground,
            tint: .appTextPrimary,
            pointSize: 15
        )
        closeButton.addTarget(self, action: #selector(tapClose), for: .touchUpInside)

        let strings = CallStrings.current
        let titleLabel = makeLabel(strings.unreachableTitle, size: 17, weight: .semibold, color: .appTextPrimary)
        let statusLabel = makeLabel(strings.unreachableHeadline, size: 15, weight: .regular, color: .appDecline)

        let avatar = UIImageView(image: CallAppearance.current.avatarPlaceholder)
        avatar.tintColor = CallAppearance.current.avatarPlaceholderTint
        avatar.contentMode = .scaleAspectFit

        let nameLabel = makeLabel(callerName, size: 22, weight: .semibold, color: .appTextPrimary)

        let messageLabel = makeLabel(
            strings.unreachableSubtitle,
            size: 14, weight: .regular, color: .appTextSecondary
        )
        messageLabel.numberOfLines = 0

        let tryAgainButton = CallOptionButton()
        tryAgainButton.configure(style: .primary, title: strings.tryAgain)
        tryAgainButton.addTarget(self, action: #selector(tapTryAgain), for: .touchUpInside)

        [closeButton, titleLabel, statusLabel, avatar, nameLabel, messageLabel,
         tryAgainButton].forEach {
            view.addSubview($0)
        }

        let guide = view.safeAreaLayoutGuide
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(guide).offset(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(guide).offset(12)
            make.centerX.equalToSuperview()
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
        avatar.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(110)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(16)
            make.leading.trailing.equalTo(guide).inset(24)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(24)
            make.leading.trailing.equalTo(guide).inset(32)
        }
        tryAgainButton.snp.makeConstraints { make in
            make.bottom.equalTo(guide).offset(-24)
            make.leading.trailing.equalTo(guide).inset(24)
        }
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.textAlignment = .center
        return label
    }

    // MARK: - Actions

    @objc private func tapClose() { router?.trigger(.backToHome) }
    @objc private func tapTryAgain() { router?.trigger(.retryCall(destinationIdentity: destinationIdentity)) }
}

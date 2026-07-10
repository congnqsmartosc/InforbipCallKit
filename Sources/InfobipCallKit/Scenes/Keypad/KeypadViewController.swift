import UIKit
import SnapKit
import XCoordinator

/// Bàn phím số trong cuộc gọi — theo prototype: tên/số + lưới phím + hàng nút (gọi / kết thúc / ẩn phím).
final class KeypadViewController: UIViewController {

    var router: UnownedRouter<CallRoute>?

    private let callerName: String
    private var dialed = ""
    private let gradientLayer = CAGradientLayer()

    private let nameLabel = UILabel()
    private let numberLabel = UILabel()

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["*", "0", "#"]
    ]

    init(callerName: String) {
        self.callerName = callerName
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

    private func setupBackground() {
        view.backgroundColor = .systemBackground
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.appAccent.withAlphaComponent(0.12).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        nameLabel.text = callerName
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .appTextPrimary
        nameLabel.textAlignment = .center

        numberLabel.text = " "
        numberLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .regular)
        numberLabel.textColor = .appTextSecondary
        numberLabel.textAlignment = .center

        // Lưới phím
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 16
        grid.alignment = .center
        for row in keys {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 24
            rowStack.distribution = .equalSpacing
            row.forEach { rowStack.addArrangedSubview(keyButton($0)) }
            grid.addArrangedSubview(rowStack)
        }

        // Hàng nút dưới: ẩn phím / kết thúc
        let hideButton = CircleIconButton(diameter: 56)
        hideButton.configure(icon: UIImage(systemName: "chevron.down"), background: .secondarySystemBackground, tint: .appTextPrimary, pointSize: 20)
        hideButton.addTarget(self, action: #selector(tapHide), for: .touchUpInside)

        let endButton = CircleIconButton(diameter: 68)
        endButton.configure(icon: UIImage(systemName: "phone.down.fill"), background: .appDecline, pointSize: 26)
        endButton.addTarget(self, action: #selector(tapEnd), for: .touchUpInside)

        let spacer = UIView()
        spacer.snp.makeConstraints { make in make.width.equalTo(56) }

        let bottomRow = UIStackView(arrangedSubviews: [hideButton, endButton, spacer])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .equalSpacing

        [nameLabel, numberLabel, grid, bottomRow].forEach {
            view.addSubview($0)
        }

        let guide = view.safeAreaLayoutGuide
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(guide).offset(24)
            make.leading.trailing.equalTo(guide).inset(24)
        }
        numberLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(guide).inset(24)
        }
        grid.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomRow.snp.top).offset(-32)
        }
        bottomRow.snp.makeConstraints { make in
            make.leading.trailing.equalTo(guide).inset(48)
            make.bottom.equalTo(guide).offset(-40)
        }
    }

    private func keyButton(_ digit: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(digit, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .regular)
        button.setTitleColor(.appTextPrimary, for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 36
        button.layer.masksToBounds = true
        button.snp.makeConstraints { make in make.size.equalTo(72) }
        button.addTarget(self, action: #selector(tapKey(_:)), for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func tapKey(_ sender: UIButton) {
        dialed += sender.title(for: .normal) ?? ""
        numberLabel.text = dialed
    }

    @objc private func tapHide() { router?.trigger(.closeKeypad) }
    @objc private func tapEnd() { router?.trigger(.backToHome) }
}

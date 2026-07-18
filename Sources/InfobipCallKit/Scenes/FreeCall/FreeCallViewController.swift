import UIKit
import SDWebImage

/// Màn cuộc gọi Free call: tiêu đề + avatar + tên + hàng điều khiển (Speaker/Mute)
/// + nút hành động. Toàn bộ state (pha gọi, đồng hồ, mute/loa) do FreeCallViewModel cấp;
/// layout tách sang FreeCallViewController+UI.swift.
final class FreeCallViewController: UIViewController {

    private let viewModel: FreeCallViewModel

    // Views — dựng ở extension +UI.
    let gradientLayer = CAGradientLayer()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let avatarView = UIImageView()
    let nameLabel = UILabel()

    let speakerControl = CallControlItem()
    let muteControl = CallControlItem()

    let declineButton = CircleIconButton(diameter: 68)
    let acceptButton = CircleIconButton(diameter: 68)
    let actionStack = UIStackView()

    init(viewModel: FreeCallViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) chưa hỗ trợ")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
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
        // CAGradientLayer cgColors don't auto-update on Light/Dark change — re-resolve them.
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyGradientColors()
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        nameLabel.text = viewModel.callerName
        avatarView.sd_setImage(
            with: viewModel.avatarURL,
            placeholderImage: CallAppearance.current.avatarPlaceholder
        )

        viewModel.onStatusText = { [weak self] text in
            self?.subtitleLabel.text = text
        }
        viewModel.onPhaseChange = { [weak self] phase in
            self?.apply(phase)
        }
        viewModel.onMuteChange = { [weak self] muted in
            self?.muteControl.isOn = muted
        }
        viewModel.onAudioRouteChange = { [weak self] route in
            self?.applyAudioRoute(route)
        }

        speakerControl.onTap = { [weak self] in self?.viewModel.openAudioRoutes() }
        muteControl.onTap = { [weak self] in self?.viewModel.toggleMute() }
        declineButton.addTarget(self, action: #selector(tapEnd), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(tapAnswer), for: .touchUpInside)
    }

    /// Icon control "Speaker" phản ánh thiết bị đang phát: loa ngoài / iPhone / Bluetooth / tai nghe.
    private func applyAudioRoute(_ route: AudioRouteOption) {
        let strings = CallStrings.current
        let icons = CallAppearance.current.icons
        let caption: String
        let icon: UIImage?
        switch route.kind {
        case .builtin, .speaker:
            // Loa trong/ngoài giữ icon Speaker quen thuộc; phân biệt bằng trạng thái sáng.
            caption = strings.speaker
            icon = icons.speaker
        case .bluetooth:
            caption = strings.bluetooth
            icon = icons.bluetooth
        case .wired:
            caption = strings.headphones
            icon = icons.headphones
        case .other:
            caption = strings.audioGeneric
            icon = icons.audioGeneric
        }
        speakerControl.configure(icon: icon, caption: caption)
        // Sáng icon khi KHÔNG phải loa trong mặc định (đang ở loa ngoài / Bluetooth / tai nghe).
        speakerControl.isOn = route.kind != .builtin
    }

    private func apply(_ phase: FreeCallViewModel.Phase) {
        switch phase {
        case .incoming:
            acceptButton.isHidden = false
        case .connecting, .ringing:
            acceptButton.isHidden = true
        case .established:
            // Đã nối máy: chỉ còn nút kết thúc (+ mute/loa vẫn dùng được).
            acceptButton.isHidden = true
        case .ended:
            declineButton.isEnabled = false
            acceptButton.isEnabled = false
        }
    }

    // MARK: - Actions

    @objc private func tapAnswer() {
        viewModel.accept()
    }

    @objc private func tapEnd() {
        viewModel.hangUp()
    }
}

import UIKit
import SnapKit
import XCoordinator

/// Bottom sheet chọn nguồn âm thanh trong cuộc gọi — theo prototype "Speaker".
/// Danh sách lấy từ thiết bị audio thật của cuộc gọi (audioDeviceManager):
/// iPhone (loa trong) / Loa ngoài / tai nghe Bluetooth / tai nghe dây… và có thể
/// chuyển qua lại tự do (Bluetooth -> loa ngoài -> iPhone…).
final class AudioRouteSheetViewController: UIViewController {

    var router: UnownedRouter<CallRoute>?

    private let call: ActiveCall
    private var routes: [AudioRouteOption] = []
    private var checks: [UIImageView] = []

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()

    private let card = UIView()

    init(call: ActiveCall) {
        self.call = call
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) chưa hỗ trợ")
    }

    override func loadView() { view = UIView() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setup()
    }

    private func setup() {
        routes = call.audioRoutes
        // Phòng hờ SDK chưa trả thiết bị nào: tối thiểu vẫn cho chọn iPhone / Loa ngoài.
        if routes.isEmpty {
            routes = [
                AudioRouteOption(id: "fallback-builtin", name: CallStrings.current.routeBuiltIn, kind: .builtin, isActive: !call.isSpeakerOn),
                AudioRouteOption(id: "fallback-speaker", name: CallStrings.current.routeSpeaker, kind: .speaker, isActive: call.isSpeakerOn)
            ]
        }

        card.backgroundColor = .appSurface
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous

        let title = UILabel()
        title.text = CallStrings.current.audioSourceTitle
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        title.textColor = .appTextPrimary
        title.textAlignment = .center

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        for (index, route) in routes.enumerated() {
            stack.addArrangedSubview(makeRow(route, tag: index))
        }

        view.addSubview(dimmingView)
        view.addSubview(card)
        card.addSubview(title)
        card.addSubview(stack)

        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        stack.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDim))
        dimmingView.addGestureRecognizer(tap)
    }

    private func makeRow(_ route: AudioRouteOption, tag: Int) -> UIControl {
        let row = UIControl()
        row.tag = tag

        let icon = UIImageView(image: UIImage(systemName: route.iconName))
        icon.tintColor = .appTextPrimary
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = route.name
        label.font = .systemFont(ofSize: 16)
        label.textColor = .appTextPrimary
        label.lineBreakMode = .byTruncatingTail

        let check = UIImageView(image: UIImage(systemName: "checkmark"))
        check.tintColor = .appAccent
        check.contentMode = .scaleAspectFit
        check.isHidden = !route.isActive
        checks.append(check)

        [icon, label, check].forEach { row.addSubview($0); $0.isUserInteractionEnabled = false }

        row.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.equalTo(26)
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(check.snp.leading).offset(-8)
        }
        check.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }

        row.addTarget(self, action: #selector(tapRow(_:)), for: .touchUpInside)
        return row
    }

    @objc private func tapRow(_ sender: UIControl) {
        let index = sender.tag
        guard routes.indices.contains(index) else { return }
        for (checkIndex, check) in checks.enumerated() {
            check.isHidden = (checkIndex != index)
        }

        let route = routes[index]
        if route.id.hasPrefix("fallback-") {
            call.setSpeakerphone(route.kind == .speaker)
        } else {
            call.selectAudioRoute(id: route.id)
        }

        // Chọn xong đóng sheet (giữ lại 0.15s cho thấy checkmark).
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.router?.trigger(.dismiss)
        }
    }

    @objc private func tapDim() {
        router?.trigger(.dismiss)
    }
}

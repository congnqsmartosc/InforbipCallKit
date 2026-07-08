import UIKit
import SnapKit

/// Overlay hiển thị banner cuộc gọi đến ở đỉnh màn hình (present .overFullScreen, nền trong suốt).
final class IncomingCallViewController: UIViewController {

    private let viewModel: IncomingCallViewModel
    private let banner = IncomingCallBannerView()

    init(viewModel: IncomingCallViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) chưa hỗ trợ")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        banner.configure(callerName: viewModel.callerName, avatarURL: viewModel.avatarURL)
        banner.onAccept = { [weak self] in self?.viewModel.accept() }
        banner.onDecline = { [weak self] in self?.viewModel.decline() }
        banner.onTapBanner = { [weak self] in self?.viewModel.openFullScreen() }

        view.addSubview(banner)
        banner.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
    }
}

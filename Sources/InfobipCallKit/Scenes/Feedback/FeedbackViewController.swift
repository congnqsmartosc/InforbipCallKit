import UIKit
import SnapKit
import XCoordinator

/// Bottom sheet "Share feedback" hiện sau khi kết thúc cuộc gọi.
/// Overlay .overFullScreen: nền mờ + card đánh giá neo đáy. Submit/Skip/tap-nền đều -> về Home.
final class FeedbackViewController: UIViewController {

    var router: UnownedRouter<CallRoute>?
    /// Forwards the submitted rating (0–2 or nil) + reason strings to the host.
    var onFeedback: ((Int?, [String]) -> Void)?

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()

    private let feedbackView = FeedbackView()

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    // Tạo view bằng code, chặn UIKit tự tìm nib trùng tên ("FeedbackViewController"
    // bỏ hậu tố Controller = "FeedbackView" trùng FeedbackView.xib -> nối nhầm outlet -> crash).
    override func loadView() {
        view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        view.addSubview(dimmingView)
        view.addSubview(feedbackView)

        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        feedbackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }

        feedbackView.onSubmit = { [weak self] rating, reasons in
            self?.onFeedback?(rating, reasons)
            self?.router?.trigger(.finishCall)
        }
        feedbackView.onSkip = { [weak self] in self?.router?.trigger(.finishCall) }
        feedbackView.onLayoutChange = { [weak self] in
            UIView.animate(withDuration: 0.25) { self?.view.layoutIfNeeded() }
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDim))
        dimmingView.addGestureRecognizer(tap)
    }

    @objc private func tapDim() {
        router?.trigger(.finishCall)
    }
}

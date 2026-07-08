import UIKit
import SnapKit
import SDWebImage

/// Banner cuộc gọi đến kiểu thông báo. UI dựng trong IncomingCallBannerView.xib (File's Owner):
/// avatar người gọi + "Xanh SM" + tên người gọi + nút từ chối (đỏ) / nhận (xanh).
/// Chạm vào thân banner (ngoài 2 nút) -> mở màn gọi đầy đủ.
final class IncomingCallBannerView: UIView {

    var onAccept: (() -> Void)?
    var onDecline: (() -> Void)?
    var onTapBanner: (() -> Void)?

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var appLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var declineButton: CircleIconButton!
    @IBOutlet private weak var acceptButton: CircleIconButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let nib = UINib(nibName: "IncomingCallBannerView", bundle: .callKit)
        nib.instantiate(withOwner: self)

        guard let content = contentView else {
            assertionFailure("Không nối được outlet 'contentView' trong IncomingCallBannerView.xib")
            return
        }
        addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        style()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBanner))
        tap.delegate = self
        content.addGestureRecognizer(tap)
    }

    private func style() {
        backgroundColor = .clear
        contentView.backgroundColor = .appSurface
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.12
        contentView.layer.shadowRadius = 12
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)

        iconView.image = UIImage(systemName: "phone.circle.fill")
        iconView.tintColor = .appAccent
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true

        appLabel.text = "Xanh SM"
        appLabel.font = .systemFont(ofSize: 12, weight: .medium)
        appLabel.textColor = .appTextSecondary
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .appTextPrimary

        declineButton.diameter = 40
        acceptButton.diameter = 40
        declineButton.configure(icon: UIImage(systemName: "xmark"), background: .appDecline, pointSize: 16)
        acceptButton.configure(icon: UIImage(systemName: "phone.fill"), background: .appAccept, pointSize: 16)
        declineButton.addTarget(self, action: #selector(tapDecline), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(tapAccept), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.layer.cornerRadius = iconView.bounds.width / 2
    }

    func configure(callerName: String, avatarURL: URL? = nil) {
        nameLabel.text = callerName
        if let avatarURL = avatarURL {
            iconView.sd_setImage(with: avatarURL, placeholderImage: UIImage(systemName: "phone.circle.fill"))
        }
    }

    @objc private func tapAccept() { onAccept?() }
    @objc private func tapDecline() { onDecline?() }
    @objc private func tapBanner() { onTapBanner?() }
}

// MARK: - UIGestureRecognizerDelegate

extension IncomingCallBannerView: UIGestureRecognizerDelegate {
    /// Không nuốt touch của 2 nút nhận/từ chối (kể cả khi chạm vào icon bên trong nút).
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var current: UIView? = touch.view
        while let view = current {
            if view is UIControl { return false }
            current = view.superview
        }
        return true
    }
}

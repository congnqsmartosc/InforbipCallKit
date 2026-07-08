import UIKit
import SnapKit

/// Nút bấm dạng "pill" tái sử dụng, có 2 style: primary (nền teal) và secondary (viền).
/// Dùng chung cho nút gọi SIM, Free call và các CTA khác.
///
/// Đặt custom class = CallOptionButton cho UIButton trong .xib để dùng lại trong Interface Builder.
final class CallOptionButton: UIButton {

    enum Style {
        case primary   // nền đặc, chữ trắng
        case secondary // trong suốt, viền + chữ theo màu nhấn
    }

    private var style: Style = .primary

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBase()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBase()
    }

    private func setupBase() {
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        // Padding trong nút. (contentEdgeInsets bị deprecate ở iOS 15 nhưng vẫn chạy đúng;
        // giữ để tương thích rộng cho POC.)
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        adjustsImageWhenHighlighted = false

        // Chiều cao tối thiểu ổn định trên mọi screen size.
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(52)
        }
    }

    // MARK: - Config

    func configure(style: Style, title: String, icon: UIImage? = nil) {
        self.style = style
        setTitle(title, for: .normal)
        setImage(icon, for: .normal)
        applyStyle()
    }

    private func applyStyle() {
        switch style {
        case .primary:
            backgroundColor = .appAccent
            setTitleColor(.white, for: .normal)
            tintColor = .white
            layer.borderWidth = 0
        case .secondary:
            backgroundColor = .clear
            setTitleColor(.appAccent, for: .normal)
            tintColor = .appAccent
            layer.borderWidth = 1.5
            layer.borderColor = UIColor.appAccent.cgColor
        }
    }

    // Giữ màu viền đúng khi chuyển Light/Dark.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if style == .secondary {
            layer.borderColor = UIColor.appAccent.cgColor
        }
    }

    // Hiệu ứng nhấn nhẹ.
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

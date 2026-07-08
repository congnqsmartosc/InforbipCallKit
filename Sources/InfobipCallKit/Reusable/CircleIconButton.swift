import UIKit
import SnapKit

/// Nút tròn đặc chứa 1 icon SF Symbol.
/// Dùng được cả bằng code (init(diameter:)) lẫn trong Interface Builder (@IBInspectable diameter).
final class CircleIconButton: UIButton {

    /// Đường kính nút. Set trong IB qua Attributes, hoặc qua init(diameter:).
    @IBInspectable var diameter: CGFloat = 64 {
        didSet { applyDiameter() }
    }

    private var sizeConstraint: Constraint?

    init(diameter: CGFloat = 64) {
        super.init(frame: .zero)
        self.diameter = diameter
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.masksToBounds = true
        snp.makeConstraints { make in
            sizeConstraint = make.size.equalTo(diameter).constraint
        }
        applyDiameter()
    }

    private func applyDiameter() {
        sizeConstraint?.update(offset: diameter)
        layer.cornerRadius = diameter / 2
    }

    func configure(icon: UIImage?, background: UIColor, tint: UIColor = .white, pointSize: CGFloat = 24) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        setImage(icon?.withConfiguration(config), for: .normal)
        backgroundColor = background
        tintColor = tint
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) { self.alpha = self.isHighlighted ? 0.75 : 1.0 }
        }
    }
}

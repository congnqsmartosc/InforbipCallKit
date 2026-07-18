import UIKit
import SnapKit

/// 1 mục điều khiển trong cuộc gọi: icon tròn + nhãn bên dưới (Speaker / Mute / Message).
/// UI dựng trong CallControlItem.xib (File's Owner). Có trạng thái bật/tắt + callback khi bấm.
final class CallControlItem: UIControl {

    var onTap: (() -> Void)?

    var isOn: Bool = false {
        didSet { updateAppearance() }
    }

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var iconContainer: UIView!
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let nib = UINib(nibName: "CallControlItem", bundle: .callKit)
        nib.instantiate(withOwner: self)

        guard let content = contentView else {
            assertionFailure("Không nối được outlet 'contentView' trong CallControlItem.xib")
            return
        }
        content.isUserInteractionEnabled = false // để touch xuyên xuống UIControl
        addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let diameter = CallAppearance.current.controlIconDiameter
        iconContainer.layer.cornerRadius = diameter / 2
        iconContainer.layer.masksToBounds = true
        // Update the xib's fixed width/height constraints in place (don't remake — that would drop
        // the container's position constraints from the nib).
        iconContainer.constraints.forEach { c in
            if c.firstAttribute == .width || c.firstAttribute == .height { c.constant = diameter }
        }
        captionLabel.font = CallAppearance.current.captionFont

        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        updateAppearance()
    }

    private var isToggle = false
    private var offIcon: UIImage?
    private var onIcon: UIImage?
    private var offCaption: String?
    private var onCaption: String?

    func configure(icon: UIImage?, caption: String) {
        isToggle = false
        iconView.image = icon
        captionLabel.text = caption
    }

    /// Nút 2 trạng thái: đổi icon + chữ khi bật/tắt (vd Mute ↔ Unmute).
    func configureToggle(offIcon: UIImage?, onIcon: UIImage?, offCaption: String, onCaption: String) {
        isToggle = true
        self.offIcon = offIcon
        self.onIcon = onIcon
        self.offCaption = offCaption
        self.onCaption = onCaption
        updateAppearance()
    }

    private func updateAppearance() {
        iconContainer.backgroundColor = isOn ? .appControlOn : .appControlOff
        iconView.tintColor = isOn ? .appAccent : .appTextPrimary
        if isToggle {
            iconView.image = isOn ? onIcon : offIcon
            captionLabel.text = isOn ? onCaption : offCaption
        }
    }

    @objc private func didTap() {
        onTap?()
    }
}

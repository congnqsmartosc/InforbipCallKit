import UIKit
import SnapKit

/// Card "Share feedback" — đánh giá cuộc gọi bằng 3 mức emoji; chọn xong hiện thêm chip lý do,
/// rồi Submit/Skip. UI khung dựng trong FeedbackView.xib (File's Owner), phần chip lý do thêm bằng code.
final class FeedbackView: UIView {

    /// Trả về (mức đã chọn 0..2 hoặc nil, danh sách lý do đã chọn).
    var onSubmit: ((Int?, [String]) -> Void)?
    var onSkip: (() -> Void)?
    /// Báo cho VC biết chiều cao thay đổi (để animate sheet phình ra).
    var onLayoutChange: (() -> Void)?

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emoji1: UIButton!
    @IBOutlet private weak var emoji2: UIButton!
    @IBOutlet private weak var emoji3: UIButton!
    @IBOutlet private weak var submitButton: CallOptionButton!
    @IBOutlet private weak var skipButton: CallOptionButton!

    private var selectedRating: Int?
    private var emojiButtons: [UIButton] { [emoji1, emoji2, emoji3] }

    private let reasons = ["Âm thanh bị ngắt quãng", "Không nghe rõ", "Kết nối chậm", "Gọi bị rớt giữa chừng"]
    private var reasonButtons: [UIButton] = []
    private var selectedReasons = Set<Int>()
    private let reasonsStack = UIStackView()

    override init(frame: CGRect) { super.init(frame: frame); commonInit() }
    required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        let nib = UINib(nibName: "FeedbackView", bundle: .callKit)
        nib.instantiate(withOwner: self)

        guard let content = contentView else {
            assertionFailure("Không nối được outlet 'contentView' trong FeedbackView.xib")
            return
        }
        addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        style()
    }

    private func style() {
        backgroundColor = .clear
        contentView.backgroundColor = .appSurface
        contentView.layer.cornerRadius = 20
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true

        titleLabel.text = "Cuộc gọi vừa rồi thế nào?"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .appTextPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let emojis = ["😞", "😐", "😄"]
        for (i, button) in emojiButtons.enumerated() {
            button.setTitle(emojis[i], for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 32)
            button.backgroundColor = .secondarySystemBackground
            button.layer.cornerRadius = 14
            button.layer.cornerCurve = .continuous
            button.layer.borderColor = UIColor.appAccent.cgColor
            button.tag = i
            button.addTarget(self, action: #selector(tapEmoji(_:)), for: .touchUpInside)
        }

        buildReasons()

        submitButton.configure(style: .primary, title: "Gửi đánh giá")
        skipButton.configure(style: .secondary, title: "Bỏ qua")
        submitButton.addTarget(self, action: #selector(tapSubmit), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(tapSkip), for: .touchUpInside)
    }

    /// Chèn khối chip lý do (ẩn ban đầu) vào giữa hàng emoji và nút Submit.
    private func buildReasons() {
        reasonsStack.axis = .vertical
        reasonsStack.spacing = 8
        reasonsStack.isHidden = true

        for (i, reason) in reasons.enumerated() {
            let chip = UIButton(type: .system)
            chip.setTitle(reason, for: .normal)
            chip.contentHorizontalAlignment = .leading
            chip.titleLabel?.font = .systemFont(ofSize: 14)
            chip.setTitleColor(.appTextPrimary, for: .normal)
            chip.backgroundColor = .secondarySystemBackground
            chip.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            chip.layer.cornerRadius = 10
            chip.layer.cornerCurve = .continuous
            chip.layer.borderColor = UIColor.appAccent.cgColor
            chip.tag = i
            chip.addTarget(self, action: #selector(tapReason(_:)), for: .touchUpInside)
            reasonButtons.append(chip)
            reasonsStack.addArrangedSubview(chip)
        }

        if let vstack = submitButton.superview as? UIStackView {
            let index = vstack.arrangedSubviews.firstIndex(of: submitButton) ?? vstack.arrangedSubviews.count
            vstack.insertArrangedSubview(reasonsStack, at: index)
        }
    }

    @objc private func tapEmoji(_ sender: UIButton) {
        selectedRating = sender.tag
        for button in emojiButtons {
            let selected = (button === sender)
            button.layer.borderWidth = selected ? 2 : 0
            button.backgroundColor = selected
                ? UIColor.appAccent.withAlphaComponent(0.12)
                : .secondarySystemBackground
        }
        if reasonsStack.isHidden {
            reasonsStack.isHidden = false
            onLayoutChange?()
        }
    }

    @objc private func tapReason(_ sender: UIButton) {
        let i = sender.tag
        if selectedReasons.contains(i) { selectedReasons.remove(i) } else { selectedReasons.insert(i) }
        let on = selectedReasons.contains(i)
        sender.layer.borderWidth = on ? 1.5 : 0
        sender.backgroundColor = on ? UIColor.appAccent.withAlphaComponent(0.12) : .secondarySystemBackground
    }

    @objc private func tapSubmit() {
        onSubmit?(selectedRating, selectedReasons.sorted().map { reasons[$0] })
    }

    @objc private func tapSkip() { onSkip?() }

    // MARK: - Debug (để chụp màn hình có chip lý do)

    #if DEBUG
    func debugSelectFirstRating() { tapEmoji(emoji1) }
    #endif
}

import UIKit
import AVFoundation
import InfobipCallKit

/// Minimal host screen demonstrating integration:
/// 1. pick an identity (this device) → mint a token (host backend) → registerSubscriber + listen
/// 2. tap "Call the other side" → client.startOutgoingCall(...); the framework presents all UI.
final class HomeViewController: UIViewController {

    private let center: InfobipCallCenter

    // Demo identity pair — this device registers as one, calls the other.
    private let identities = ["driver", "customer"]
    private let displayNames = ["driver": "Nguyễn Văn Nam", "customer": "Trần Thị Hoa"]
    private let avatars = [
        "driver": "https://i.pravatar.cc/300?img=12",
        "customer": "https://i.pravatar.cc/300?u=gsmcall-customer"
    ]

    private var myIdentity: String?
    private let roleControl = UISegmentedControl(items: ["driver", "customer"])
    private let themeControl = UISegmentedControl(items: ["Teal", "Indigo"])
    private let languageControl = UISegmentedControl(items: ["English", "Tiếng Việt"])
    private let statusLabel = UILabel()
    private let callButton = UIButton(type: .system)

    /// Two demo call-UI themes the host can switch between at runtime (colors + fonts + strings).
    private static let tealTheme = InfobipCallAppearance(
        accent: .systemTeal,
        gradientBottom: UIColor.systemTeal.withAlphaComponent(0.14)
    )
    private static let indigoTheme = InfobipCallAppearance(
        accent: .systemIndigo,
        gradientBottom: UIColor.systemIndigo.withAlphaComponent(0.16),
        titleFont: HomeViewController.rounded(17, .semibold),
        nameFont: HomeViewController.rounded(24, .bold),
        statusFont: HomeViewController.rounded(15, .regular),
        buttonFont: HomeViewController.rounded(16, .semibold)
    )

    private static func rounded(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }

    /// Two in-code language packs for the call UI. English is the pod default; Vietnamese overrides
    /// every string. A real app could build these from `NSLocalizedString` / a String Catalog.
    private static let englishStrings = InfobipCallStrings()   // English defaults
    private static let vietnameseStrings = InfobipCallStrings(
        callTitle: "Cuộc gọi",
        statusConnecting: "Đang kết nối…",
        statusRinging: "Đang đổ chuông…",
        statusReconnecting: "Đang kết nối lại…",
        statusIncoming: "Đang gọi bạn",
        statusCallEnded: "Cuộc gọi đã kết thúc",
        speaker: "Loa",
        mute: "Tắt tiếng",
        unmute: "Bật tiếng",
        bluetooth: "Bluetooth",
        headphones: "Tai nghe",
        audioGeneric: "Âm thanh",
        audioSourceTitle: "Nguồn âm thanh",
        routeBuiltIn: "iPhone",
        routeSpeaker: "Loa ngoài",
        incomingBrandLabel: "Cuộc gọi đến",
        unreachableTitle: "Cuộc gọi",
        unreachableHeadline: "Người nhận không trả lời",
        unreachableSubtitle: "Họ có thể đang không sẵn sàng.\nThử lại?",
        tryAgain: "Thử lại",
        sendMessage: "Gửi tin nhắn",
        micPermissionTitle: "Cần quyền micro",
        micPermissionMessage: "Vui lòng cho phép truy cập micro trong Cài đặt để thực hiện cuộc gọi.",
        micOpenSettings: "Mở Cài đặt",
        micDismiss: "Bỏ qua"
    )

    /// Retain the event observation for the lifetime of this screen.
    private var eventToken: ObservationToken?

    /// Persisted so the app can re-register (and refresh the Infobip push binding) on every launch —
    /// required for background/killed-app calls to keep ringing this device.
    private static let savedIdentityKey = "InfobipCallKitExample.savedIdentity"

    init(center: InfobipCallCenter) {
        self.center = center
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        observeCallEvents()
        restoreSavedIdentity()
        applySelectedTheme()      // default call-UI appearance
        applySelectedLanguage()   // default call-UI language
    }

    /// On launch, re-register the previously-picked identity so the Infobip push binding stays alive
    /// and this device keeps receiving background/killed-app calls.
    private func restoreSavedIdentity() {
        guard let saved = UserDefaults.standard.string(forKey: Self.savedIdentityKey),
              let index = identities.firstIndex(of: saved) else { return }
        roleControl.selectedSegmentIndex = index
        register(identity: saved)
    }

    /// Demonstrates the SDK event stream — every call lifecycle/signal/control event is delivered
    /// here. A host would use these for analytics, CallKit reporting, logging, etc.
    private func observeCallEvents() {
        eventToken = center.client.observeEvents { event in
            switch event {
            case .started(let session):
                print("[Example] call started → \(session.counterpartDisplayName) (\(session.direction))")
            case .ringing:            print("[Example] ringing")
            case .connecting:         print("[Example] connecting")
            case .established:        print("[Example] established")
            case .ended(let reason):
                // reason.category classifies the raw SDK code (e.g. .unavailable = callee offline).
                print("[Example] call ended: \(reason.category) — \(reason.name) (code \(reason.code)) \(reason.message)")
            case .networkQualityChanged(let quality):
                print("[Example] network quality: \(quality)")
            case .reconnecting:        print("[Example] reconnecting… (this device lost network)")
            case .reconnected:         print("[Example] reconnected")
            case .remoteDisconnected:  print("[Example] remote party lost network")
            case .remoteReconnected:   print("[Example] remote party reconnected")
            case .muteChanged(let muted):     print("[Example] muted: \(muted)")
            case .speakerChanged(let on):     print("[Example] speaker: \(on)")
            case .audioRouteChanged(let name): print("[Example] audio route: \(name)")
            }
        }
    }

    private func setupUI() {
        let title = UILabel()
        title.text = "InfobipCallKit Example"
        title.font = .boldSystemFont(ofSize: 20)
        title.textAlignment = .center

        roleControl.selectedSegmentIndex = UISegmentedControl.noSegment
        roleControl.addTarget(self, action: #selector(didPickRole), for: .valueChanged)

        let themeCaption = UILabel()
        themeCaption.text = "Call UI theme"
        themeCaption.font = .systemFont(ofSize: 13, weight: .medium)
        themeCaption.textColor = .secondaryLabel
        themeCaption.textAlignment = .center
        themeControl.selectedSegmentIndex = 0
        themeControl.addTarget(self, action: #selector(didPickTheme), for: .valueChanged)

        let languageCaption = UILabel()
        languageCaption.text = "Call UI language"
        languageCaption.font = .systemFont(ofSize: 13, weight: .medium)
        languageCaption.textColor = .secondaryLabel
        languageCaption.textAlignment = .center
        languageControl.selectedSegmentIndex = 0
        languageControl.addTarget(self, action: #selector(didPickLanguage), for: .valueChanged)

        statusLabel.text = "Pick a role to register and listen for calls."
        statusLabel.font = .systemFont(ofSize: 13)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center

        callButton.setTitle("Call the other side", for: .normal)
        callButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        callButton.isEnabled = false
        callButton.addTarget(self, action: #selector(didTapCall), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, roleControl, themeCaption, themeControl, languageCaption, languageControl, statusLabel, callButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    @objc private func didPickRole() {
        let identity = identities[roleControl.selectedSegmentIndex]
        UserDefaults.standard.set(identity, forKey: Self.savedIdentityKey)
        register(identity: identity)
    }

    /// Switch the call-UI theme (appearance only) at runtime — applies to the next call screen.
    @objc private func didPickTheme() { applySelectedTheme() }

    private func applySelectedTheme() {
        let isIndigo = themeControl.selectedSegmentIndex == 1
        center.updateAppearance(isIndigo ? Self.indigoTheme : Self.tealTheme)
    }

    /// Switch the call-UI language at runtime — applies to the next call screen.
    @objc private func didPickLanguage() { applySelectedLanguage() }

    private func applySelectedLanguage() {
        let isVietnamese = languageControl.selectedSegmentIndex == 1
        center.updateStrings(isVietnamese ? Self.vietnameseStrings : Self.englishStrings)
    }

    private func register(identity: String) {
        myIdentity = identity
        statusLabel.text = "Registering \"\(identity)\"…"
        roleControl.isEnabled = false

        Task {
            do {
                let token = try await DemoTokenProvider.token(
                    identity: identity, displayName: displayNames[identity] ?? identity
                )
                // Pass the subscriber's own name + avatar; the SDK auto-forwards them to the
                // callee on outgoing calls, so we no longer build customData by hand below.
                try await center.client.registerSubscriber(
                    identity: identity,
                    displayName: displayNames[identity] ?? identity,
                    token: token,
                    imageURL: avatars[identity]
                )
                try await center.client.registerForIncomingCalls()
                // Ask for mic permission eagerly so answering from the lock screen never needs a
                // prompt that can't be shown there.
                AVAudioSession.sharedInstance().requestRecordPermission { _ in }
                statusLabel.text = "Registered as \(identity). Ready for calls."
                callButton.isEnabled = true
            } catch {
                statusLabel.text = "Register failed: \(error.localizedDescription)"
                roleControl.isEnabled = true
            }
        }
    }

    @objc private func didTapCall() {
        guard let me = myIdentity else { return }
        let destination = identities.first { $0 != me } ?? me
        // Pass the callee's display info so the outgoing screen shows their name/avatar (the pod
        // can't derive it from the identity). The caller's own info is auto-forwarded to the callee.
        Task {
            do {
                _ = try await center.client.startOutgoingCall(
                    destinationIdentity: destination,
                    displayName: displayNames[destination] ?? destination,
                    imageURL: avatars[destination]
                )
            } catch {
                presentAlert(error.localizedDescription)
            }
        }
    }

    private func presentAlert(_ message: String) {
        let alert = UIAlertController(title: "Call failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

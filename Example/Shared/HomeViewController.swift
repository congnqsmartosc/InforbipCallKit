import UIKit
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
    private let statusLabel = UILabel()
    private let callButton = UIButton(type: .system)

    init(center: InfobipCallCenter) {
        self.center = center
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
    }

    private func setupUI() {
        let title = UILabel()
        title.text = "InfobipCallKit Example"
        title.font = .boldSystemFont(ofSize: 20)
        title.textAlignment = .center

        roleControl.selectedSegmentIndex = UISegmentedControl.noSegment
        roleControl.addTarget(self, action: #selector(didPickRole), for: .valueChanged)

        statusLabel.text = "Pick a role to register and listen for calls."
        statusLabel.font = .systemFont(ofSize: 13)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center

        callButton.setTitle("Call the other side", for: .normal)
        callButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        callButton.isEnabled = false
        callButton.addTarget(self, action: #selector(didTapCall), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, roleControl, statusLabel, callButton])
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
        myIdentity = identity
        statusLabel.text = "Registering \"\(identity)\"…"
        roleControl.isEnabled = false

        Task {
            do {
                let token = try await DemoTokenProvider.token(
                    identity: identity, displayName: displayNames[identity] ?? identity
                )
                try await center.client.registerSubscriber(
                    identity: identity, displayName: displayNames[identity] ?? identity, token: token
                )
                try await center.client.registerForIncomingCalls()
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
        // Forward THIS caller's display info to the callee via customData.
        let customData = [
            "displayName": displayNames[me] ?? me,
            "avatarUrl": avatars[me] ?? ""
        ]
        Task {
            do {
                _ = try await center.client.startOutgoingCall(destinationIdentity: destination, customData: customData)
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

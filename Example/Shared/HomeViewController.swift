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
    private let statusLabel = UILabel()
    private let callButton = UIButton(type: .system)

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
                print("[Example] call ended: \(reason.name) (code \(reason.code), isError: \(reason.isError)) — \(reason.message)")
            case .networkQualityChanged(let quality):
                print("[Example] network quality: \(quality)")
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
        UserDefaults.standard.set(identity, forKey: Self.savedIdentityKey)
        register(identity: identity)
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
        // No customData needed: the SDK auto-forwards the registered subscriber's name + avatar.
        Task {
            do {
                _ = try await center.client.startOutgoingCall(destinationIdentity: destination)
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

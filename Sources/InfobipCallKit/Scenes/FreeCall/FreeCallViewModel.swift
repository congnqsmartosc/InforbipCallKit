import Foundation
import XCoordinator

/// ViewModel màn Free call — nguồn state duy nhất cho FreeCallViewController.
/// Nhận CallEvent từ ActiveCall, quyết định route khi cuộc gọi kết thúc.
final class FreeCallViewModel {

    /// Pha hiển thị của màn gọi.
    enum Phase {
        case incoming      // cuộc gọi đến, chờ nhận/từ chối
        case connecting    // gọi đi: đang kết nối
        case ringing       // gọi đi: đang đổ chuông
        case established   // 2 bên đã nối — chạy đồng hồ
        case ended
    }

    // MARK: - Output (VC bind)

    var onPhaseChange: ((Phase) -> Void)?
    var onStatusText: ((String) -> Void)?
    var onMuteChange: ((Bool) -> Void)?
    /// Route âm thanh hoạt động đổi -> VC cập nhật icon control (Speaker/Bluetooth/tai nghe).
    var onAudioRouteChange: ((AudioRouteOption) -> Void)?

    var callerName: String { call.counterpartName }
    var avatarURL: URL? { call.avatarURL }
    var isMuted: Bool { call.isMuted }
    var isSpeakerOn: Bool { call.isSpeakerOn }

    // MARK: - Private

    private let call: ActiveCall
    private let router: UnownedRouter<CallRoute>
    private let autoAccept: Bool
    /// The call was already answered elsewhere (CallKit) — enter the in-call screen without accepting.
    private let alreadyAnswered: Bool

    private var phase: Phase = .connecting
    private var observerId: UUID?
    private var displayTimer: Timer?
    /// Người dùng chủ động kết thúc khi CHƯA nối -> pop, không mở màn unreachable.
    private var didCancelLocally = false
    /// Người dùng tự bấm kết thúc -> điều hướng ngay; bên kia ngắt máy -> giữ màn 2s rồi tự thoát.
    private var didHangUpLocally = false

    init(call: ActiveCall, autoAccept: Bool, alreadyAnswered: Bool = false, router: UnownedRouter<CallRoute>) {
        self.call = call
        self.autoAccept = autoAccept
        self.alreadyAnswered = alreadyAnswered
        self.router = router

        observerId = call.observe { [weak self] event in
            self?.handle(event)
        }
    }

    deinit {
        displayTimer?.invalidate()
        if let id = observerId { call.removeObserver(id) }
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        if call.isEstablished {
            enterEstablished()
            return
        }
        switch call.direction {
        case .incoming:
            if alreadyAnswered {
                // Answered on CallKit — the SDK is already accepting; just show connecting.
                setPhase(.connecting, status: "Đang kết nối…")
            } else if autoAccept {
                setPhase(.connecting, status: "Đang kết nối…")
                call.accept()
            } else {
                setPhase(.incoming, status: "Calling you")
            }
        case .outgoing:
            setPhase(.connecting, status: "Đang kết nối…")
        }
    }

    // MARK: - Intents

    func accept() {
        setPhase(.connecting, status: "Đang kết nối…")
        call.accept()
    }

    /// Nút đỏ: từ chối / huỷ / kết thúc tuỳ pha hiện tại. Routing do CallEvent hangup đảm nhận.
    func hangUp() {
        didHangUpLocally = true
        if phase != .established {
            didCancelLocally = true
        }
        switch (call.direction, phase) {
        case (.incoming, .incoming):
            call.decline()
        default:
            call.hangup()
        }
    }

    func toggleMute() {
        call.setMuted(!call.isMuted)
    }

    func toggleSpeaker() {
        call.setSpeakerphone(!call.isSpeakerOn)
    }

    func openAudioRoutes() {
        router.trigger(.audioRoutes(call))
    }

    func openChat() {
        router.trigger(.openChat(peerName: callerName))
    }

    // MARK: - Call events

    private func handle(_ event: CallEvent) {
        CallLog.debug("event=\(event) phase=\(phase) direction=\(call.direction)", category: "FreeCallVM")
        switch event {
        case .ringing, .earlyMedia:
            if call.direction == .outgoing {
                setPhase(.ringing, status: "Đang đổ chuông…")
            }

        case .established:
            enterEstablished()

        case .networkQualityChanged:
            break   // hiển thị chất lượng mạng do host lo; UI trong pod không dùng.

        case .muteChanged(let muted):
            onMuteChange?(muted)

        case .speakerChanged:
            notifyAudioRoute()

        case .audioRouteChanged(let route):
            onAudioRouteChange?(route)

        case .hangup, .error:
            finish()
        }
    }

    private func notifyAudioRoute() {
        let route = call.activeAudioRoute ?? AudioRouteOption(
            id: "synthesized",
            name: call.isSpeakerOn ? "Loa ngoài" : "iPhone",
            kind: call.isSpeakerOn ? .speaker : .builtin,
            isActive: true
        )
        onAudioRouteChange?(route)
    }

    private func enterEstablished() {
        setPhase(.established, status: formattedDuration())
        onMuteChange?(call.isMuted)
        notifyAudioRoute()
        displayTimer?.invalidate()
        // Đồng hồ hiển thị đọc duration() từ SDK mỗi giây -> luôn đúng giờ thật của cuộc gọi.
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.onStatusText?(self.formattedDuration())
        }
    }

    private func finish() {
        let wasEstablished = phase == .established
        displayTimer?.invalidate()
        displayTimer = nil
        setPhase(.ended, status: "Cuộc gọi đã kết thúc")

        let route: CallRoute
        if wasEstablished {
            // Connected call ended — just tear down (no post-call feedback screen).
            route = .backToHome
        } else if didCancelLocally || call.direction == .incoming {
            // Mình huỷ/từ chối, hoặc người gọi bên kia đã ngắt -> thoát màn gọi.
            route = .cancelCall
        } else {
            // Gọi đi nhưng bên kia từ chối / không bắt máy.
            route = .callUnreachable(name: callerName, destinationIdentity: call.counterpartIdentity)
        }

        // Mình bấm kết thúc -> đi ngay. Bên kia ngắt -> giữ màn "đã kết thúc" 2s rồi tự thoát.
        let delay: TimeInterval = didHangUpLocally ? 0 : 2
        CallLog.debug("finish wasEstablished=\(wasEstablished) local=\(didHangUpLocally) route=\(route) delay=\(delay)", category: "FreeCallVM")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else {
                CallLog.debug("finish: view model deallocated before routing", category: "FreeCallVM")
                return
            }
            CallLog.debug("triggering route \(route)", category: "FreeCallVM")
            self.router.trigger(route)
        }
    }

    // MARK: - Helpers

    private func setPhase(_ newPhase: Phase, status: String?) {
        phase = newPhase
        onPhaseChange?(newPhase)
        if let status = status {
            onStatusText?(status)
        }
    }

    private func formattedDuration() -> String {
        let seconds = call.durationSeconds
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

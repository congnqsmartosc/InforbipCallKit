import Foundation
import XCoordinator

/// ViewModel banner cuộc gọi đến: nhận / từ chối trực tiếp, hoặc mở màn gọi đầy đủ.
final class IncomingCallViewModel {

    var callerName: String { call.counterpartName }
    var avatarURL: URL? { call.avatarURL }

    private let call: ActiveCall
    private let router: UnownedRouter<CallRoute>
    private var observerId: UUID?

    init(call: ActiveCall, router: UnownedRouter<CallRoute>) {
        self.call = call
        self.router = router

        // Người gọi ngắt máy khi banner còn hiện -> tự đóng banner.
        observerId = call.observe { [weak self] event in
            if case .hangup = event {
                self?.router.trigger(.dismiss)
            } else if case .error = event {
                self?.router.trigger(.dismiss)
            }
        }
    }

    deinit {
        if let id = observerId { call.removeObserver(id) }
    }

    func accept() {
        router.trigger(.answerIncoming(call))
    }

    func decline() {
        router.trigger(.declineIncoming(call))
    }

    /// Chạm vào thân banner -> mở màn gọi đầy đủ, CHƯA nhận máy (chuông vẫn kêu).
    func openFullScreen() {
        router.trigger(.freeCall(.incoming(call, autoAccept: false)))
    }
}

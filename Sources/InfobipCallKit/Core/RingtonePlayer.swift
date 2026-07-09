import AVFoundation
import AudioToolbox

/// Âm thanh cuộc gọi (không dùng CallKit). Toàn bộ phát bằng AudioServices (system sound)
/// — KHÔNG đụng vào AVAudioSession, vì InfobipRTC sở hữu session trong suốt cuộc gọi:
/// AVAudioPlayer giữ session lúc SDK dọn dẹp từng gây "Failed to set normal Audio mode"
/// ('!pri') -> SDK kẹt ghost call, cuộc gọi sau bị decline BUSY / UI kẹt.
/// - Chuông cuộc gọi ĐẾN (ring.caf): volume CHUÔNG + tự tắt theo gạt im lặng + rung lặp 2s.
/// - Chuông chờ cuộc gọi ĐI (ringback.caf "tút… tút…"): loop tới khi earlyMedia/established/hangup.
///   Lưu ý POC: system sound cũng bị tắt theo gạt im lặng (app Phone thật vẫn kêu ringback).
final class RingtonePlayer {

    private var ringSoundID: SystemSoundID = 0
    private var isRinging = false
    private var vibrationTimer: Timer?

    private var ringbackSoundID: SystemSoundID = 0
    private var isRingbackPlaying = false

    // MARK: - Chuông cuộc gọi đến (callee)

    func start() {
        guard !isRinging else { return }
        isRinging = true

        // SDK đã kích hoạt session playAndRecord cho cuộc gọi đến ngay khi đổ chuông
        // -> system sound bị route ra LOA TRONG (nhỏ). Ép ra loa ngoài trong lúc đổ chuông,
        // stop() sẽ trả lại route mặc định trước khi user nghe máy.
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)

        if ringSoundID == 0 {
            if let url = Bundle.callKit.url(forResource: "ring", withExtension: "caf") {
                AudioServicesCreateSystemSoundID(url as CFURL, &ringSoundID)
            } else {
                CallLog.debug("missing asset ring.caf", category: "RingtonePlayer")
            }
        }
        playRingLoop()

        vibrate()
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.vibrate()
        }
    }

    /// System sound không tự loop -> phát lại trong completion cho tới khi stop.
    private func playRingLoop() {
        guard isRinging, ringSoundID != 0 else { return }
        AudioServicesPlaySystemSoundWithCompletion(ringSoundID) { [weak self] in
            DispatchQueue.main.async { self?.playRingLoop() }
        }
    }

    // MARK: - Ringback cuộc gọi đi (caller)

    /// Gọi khi nhận event `ringing` của cuộc gọi đi. Dừng ở earlyMedia/established/hangup.
    func startRingback() {
        guard !isRingbackPlaying else { return }
        isRingbackPlaying = true

        if ringbackSoundID == 0 {
            if let url = Bundle.callKit.url(forResource: "ringback", withExtension: "caf") {
                AudioServicesCreateSystemSoundID(url as CFURL, &ringbackSoundID)
            } else {
                CallLog.debug("missing asset ringback.caf", category: "RingtonePlayer")
            }
        }
        playRingbackLoop()
    }

    private func playRingbackLoop() {
        guard isRingbackPlaying, ringbackSoundID != 0 else { return }
        AudioServicesPlaySystemSoundWithCompletion(ringbackSoundID) { [weak self] in
            DispatchQueue.main.async { self?.playRingbackLoop() }
        }
    }

    func stopRingback() {
        isRingbackPlaying = false
        if ringbackSoundID != 0 {
            AudioServicesDisposeSystemSoundID(ringbackSoundID)
            ringbackSoundID = 0
        }
    }

    // MARK: - Stop

    func stop() {
        stopRingback()
        guard isRinging || vibrationTimer != nil else { return }
        isRinging = false
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        if ringSoundID != 0 {
            AudioServicesDisposeSystemSoundID(ringSoundID)
            ringSoundID = 0
        }
        // Trả route về mặc định để cuộc gọi (nếu nhận máy) nghe ở loa trong như bình thường.
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
    }

    private func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

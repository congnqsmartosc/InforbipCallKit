import Foundation
import InfobipRTC

/// Sự kiện cuộc gọi ở mức domain — ViewModel chỉ biết enum này, không import InfobipRTC.
enum CallEvent {
    case ringing
    case earlyMedia
    case established
    /// Cuộc gọi kết thúc bình thường (SDK onHangup) — kèm lý do đã map sang `CallEndReason`.
    case hangup(CallEndReason)
    /// Cuộc gọi kết thúc do lỗi (SDK onError) — `CallEndReason.isError == true`.
    case error(CallEndReason)
    /// Chất lượng mạng đổi (SDK NetworkQualityEventListener).
    case networkQualityChanged(InfobipNetworkQuality)
    /// Mạng của thiết bị này rớt, SDK đang thử kết nối lại (onReconnecting).
    case reconnecting
    /// Kết nối của thiết bị này đã phục hồi (onReconnected).
    case reconnected
    /// Đối phương rớt mạng (onRemoteDisconnected).
    case remoteDisconnected
    /// Đối phương đã kết nối lại (onRemoteReconnected).
    case remoteReconnected
    /// Trạng thái điều khiển local (mute/loa) đổi — để mọi màn đang mở cập nhật icon.
    case muteChanged(Bool)
    case speakerChanged(Bool)
    /// Route âm thanh đang hoạt động đổi (chọn tay hoặc iOS tự chuyển khi cắm/kết nối tai nghe).
    case audioRouteChanged(AudioRouteOption)
}

/// Bọc `WebrtcCall` / `IncomingWebrtcCall` của Infobip thành model domain:
/// expose thao tác (accept/decline/hangup/mute/speaker) + phát `CallEvent` cho nhiều observer.
final class ActiveCall: NSObject {

    enum Direction {
        case incoming
        case outgoing
    }

    let direction: Direction

    private var call: Call?
    private let customData: [String: String]
    private let customDataKeys: InfobipCallConfig.CustomDataKeys
    private var observers: [UUID: (CallEvent) -> Void] = [:]

    /// Cuộc gọi đến — giữ riêng để gọi accept()/decline().
    private var incomingCall: IncomingWebrtcCall? { call as? IncomingWebrtcCall }

    // MARK: - Init

    /// Cuộc gọi đến từ IncomingWebrtcCallEvent.
    init(incomingCall: IncomingWebrtcCall, customData: [String: String], customDataKeys: InfobipCallConfig.CustomDataKeys) {
        self.direction = .incoming
        self.call = incomingCall
        self.customData = customData
        self.customDataKeys = customDataKeys
        super.init()
        incomingCall.webrtcCallEventListener = self
        incomingCall.networkQualityEventListener = self
        incomingCall.audioDeviceManager.audioDeviceEventListener = self
    }

    /// Cuộc gọi đi: tạo trước để làm listener, gắn call sau khi callWebrtc trả về.
    init(outgoingCustomData: [String: String], customDataKeys: InfobipCallConfig.CustomDataKeys) {
        self.direction = .outgoing
        self.call = nil
        self.customData = outgoingCustomData
        self.customDataKeys = customDataKeys
        super.init()
    }

    func attach(_ call: Call) {
        self.call = call
        call.networkQualityEventListener = self
        call.audioDeviceManager.audioDeviceEventListener = self
    }

    // MARK: - Caller info

    /// Tên hiển thị đối phương: ưu tiên customData do app cấp (đã forward / host cung cấp) ->
    /// displayIdentifier của endpoint (Infobip có thể trả về chính identity) -> identity.
    var counterpartName: String {
        if let name = customData[customDataKeys.displayName], !name.isEmpty {
            return name
        }
        guard let call = call else { return "" }
        let endpoint = direction == .incoming ? call.source() : call.destination()
        return endpoint.displayIdentifier() ?? endpoint.identifier()
    }

    var avatarURL: URL? {
        customData[customDataKeys.avatarURL].flatMap(URL.init(string:))
    }

    /// Counterpart identity (raw WebRTC identifier), exposed for `CallSession`.
    var counterpartIdentity: String {
        guard let call = call else { return "" }
        let endpoint = direction == .incoming ? call.source() : call.destination()
        return endpoint.identifier()
    }

    // MARK: - State

    var isEstablished: Bool { call?.establishTime() != nil }
    var durationSeconds: Int { call?.duration() ?? 0 }
    var isMuted: Bool { call?.muted() ?? false }
    var isSpeakerOn: Bool { call?.speakerphone() ?? false }

    // MARK: - Audio routes (loa trong / loa ngoài / Bluetooth…)

    /// Thiết bị audio khả dụng của cuộc gọi, đã map sang domain (không lộ InfobipRTC ra ngoài).
    var audioRoutes: [AudioRouteOption] {
        guard let call = call else { return [] }
        return call.audioDeviceManager.availableAudioDevices.map { device in
            AudioRouteOption(
                id: Self.routeId(for: device),
                name: Self.displayName(for: device),
                kind: Self.kind(of: device),
                isActive: device.isActive
            )
        }
    }

    /// Route đang hoạt động (nil khi chưa gắn call).
    var activeAudioRoute: AudioRouteOption? {
        guard let device = call?.audioDeviceManager.activeDevice else { return nil }
        return Self.option(for: device)
    }

    func selectAudioRoute(id: String) {
        guard let call = call,
              let device = call.audioDeviceManager.availableAudioDevices
                  .first(where: { Self.routeId(for: $0) == id }) else { return }
        do {
            try call.audioDeviceManager.selectAudioDevice(device)
            // Cập nhật icon ngay theo lựa chọn (listener onActiveAudioDeviceChanged
            // sẽ xác nhận lại sau — trùng cũng vô hại).
            emit(.audioRouteChanged(Self.option(for: device)))
        } catch {
            // Lỗi thao tác local — không kết thúc cuộc gọi, chỉ log.
            CallLog.debug("selectAudioRoute failed: \(error.localizedDescription)", category: "ActiveCall")
        }
    }

    private static func option(for device: AudioDevice) -> AudioRouteOption {
        AudioRouteOption(
            id: routeId(for: device),
            name: displayName(for: device),
            kind: kind(of: device),
            isActive: true
        )
    }

    private static func routeId(for device: AudioDevice) -> String {
        "\(device.portDescription.uid)#\(device.outputPortOverride.rawValue)"
    }

    private static func kind(of device: AudioDevice) -> AudioRouteOption.Kind {
        // Loa ngoài là "pseudo device" dùng port override, không phải port riêng.
        if device.outputPortOverride == .speaker { return .speaker }
        switch device.portDescription.portType {
        case .builtInReceiver, .builtInMic:
            return .builtin
        case .builtInSpeaker:
            return .speaker
        case .bluetoothHFP, .bluetoothA2DP, .bluetoothLE:
            return .bluetooth
        case .headphones, .headsetMic, .usbAudio:
            return .wired
        default:
            return .other
        }
    }

    private static func displayName(for device: AudioDevice) -> String {
        switch kind(of: device) {
        case .builtin: return CallStrings.current.routeBuiltIn
        case .speaker: return CallStrings.current.routeSpeaker
        case .bluetooth, .wired, .other: return device.name
        }
    }

    // MARK: - Actions

    /// User đã bấm nhận/từ chối/kết thúc — dùng để phân biệt cuộc gọi chết do lỗi hệ thống
    /// (SDK không lấy được call trong 3s) với do người dùng, phục vụ retry ở CallService.
    private(set) var didUserRespond = false

    var callId: String { call?.id() ?? "" }

    func accept() {
        didUserRespond = true
        incomingCall?.accept()
    }

    func decline() {
        didUserRespond = true
        // declineOnAllDevices=true: kết thúc cả dialog phía người gọi ngay.
        // Mặc định (false) chỉ ngắt leg của máy này -> người gọi vẫn đổ chuông chờ
        // thiết bị khác cùng identity, tới khi NO_ANSWER.
        incomingCall?.decline(DeclineOptions(true))
    }

    func hangup() {
        didUserRespond = true
        call?.hangup()
    }

    func setMuted(_ muted: Bool) {
        guard let call = call else { return }
        do {
            try call.mute(muted)
            emit(.muteChanged(muted))
        } catch {
            // Lỗi thao tác local — không kết thúc cuộc gọi, chỉ log.
            CallLog.debug("setMuted(\(muted)) failed: \(error.localizedDescription)", category: "ActiveCall")
        }
    }

    func setSpeakerphone(_ on: Bool) {
        call?.speakerphone(on) { [weak self] error in
            guard error == nil else { return }
            self?.emit(.speakerChanged(on))
        }
    }

    // MARK: - Observers

    /// Nhiều màn (banner, coordinator, màn gọi) cùng nghe 1 cuộc gọi -> observer theo token.
    @discardableResult
    func observe(_ handler: @escaping (CallEvent) -> Void) -> UUID {
        let id = UUID()
        observers[id] = handler
        return id
    }

    func removeObserver(_ id: UUID) {
        observers.removeValue(forKey: id)
    }

    private func emit(_ event: CallEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.observers.values.forEach { $0(event) }
        }
    }
}

// MARK: - AudioDeviceEventListener

extension ActiveCall: AudioDeviceEventListener {

    func onActiveAudioDeviceChanged(_ activeAudioDeviceChangedEvent: ActiveAudioDeviceChangedEvent) {
        emit(.audioRouteChanged(Self.option(for: activeAudioDeviceChangedEvent.activeAudioDevice)))
    }

    func onAvailableAudioDevicesChanged(_ availableAudioDevicesChangedEvent: AvailableAudioDevicesChangedEvent) {}
}

// MARK: - NetworkQualityEventListener

extension ActiveCall: NetworkQualityEventListener {

    func onNetworkQualityChanged(_ networkQualityChangedEvent: NetworkQualityChangedEvent) {
        let quality = InfobipNetworkQuality(rawValue: networkQualityChangedEvent.networkQuality.rawValue) ?? .fair
        emit(.networkQualityChanged(quality))
    }
}

// MARK: - WebrtcCallEventListener

extension ActiveCall: WebrtcCallEventListener {

    func onRinging(_ callRingingEvent: CallRingingEvent) { emit(.ringing) }
    func onEarlyMedia(_ callEarlyMediaEvent: CallEarlyMediaEvent) { emit(.earlyMedia) }
    func onEstablished(_ callEstablishedEvent: CallEstablishedEvent) { emit(.established) }

    func onHangup(_ callHangupEvent: CallHangupEvent) {
        let reason = Self.endReason(from: callHangupEvent.errorCode, isError: false)
        CallLog.debug("onHangup code=\(reason.code) name=\(reason.name)", category: "ActiveCall")
        emit(.hangup(reason))
    }

    func onError(_ errorEvent: ErrorEvent) {
        let reason = Self.endReason(from: errorEvent.errorCode, isError: true)
        CallLog.debug("onError code=\(reason.code) name=\(reason.name) message=\(reason.message)", category: "ActiveCall")
        emit(.error(reason))
    }

    private static func endReason(from errorCode: ErrorCode, isError: Bool) -> CallEndReason {
        CallEndReason(code: errorCode.id, name: errorCode.name, message: errorCode.message, isError: isError)
    }

    // Các sự kiện video / reconnect không dùng trong POC audio-only.
    func onCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {}
    func onCameraVideoUpdated(_ cameraVideoUpdatedEvent: CameraVideoUpdatedEvent) {}
    func onCameraVideoRemoved(_ cameraVideoRemovedEvent: CameraVideoRemovedEvent) {}
    func onScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {}
    func onScreenShareRemoved(_ screenShareRemovedEvent: ScreenShareRemovedEvent) {}
    func onRemoteCameraVideoAdded(_ cameraVideoAddedEvent: CameraVideoAddedEvent) {}
    func onRemoteCameraVideoRemoved() {}
    func onRemoteScreenShareAdded(_ screenShareAddedEvent: ScreenShareAddedEvent) {}
    func onRemoteScreenShareRemoved() {}
    func onRemoteMuted() {}
    func onRemoteUnmuted() {}
    func onRemoteDisconnected(_ remoteDisconnectedEvent: RemoteDisconnectedEvent) { emit(.remoteDisconnected) }
    func onRemoteReconnected(_ remoteReconnectedEvent: RemoteReconnectedEvent) { emit(.remoteReconnected) }
    func onReconnecting(_ callReconnectingEvent: CallReconnectingEvent) { emit(.reconnecting) }
    func onReconnected(_ callReconnectedEvent: CallReconnectedEvent) { emit(.reconnected) }
    func onCallRecordingStarted(_ callRecordingStartedEvent: CallRecordingStartedEvent) {}
    func onTalkingWhileMuted(_ talkingWhileMuted: TalkingWhileMutedEvent) {}
}

/// 1 lựa chọn nguồn âm thanh trong cuộc gọi.
struct AudioRouteOption: Equatable {
    enum Kind {
        case builtin    // loa trong (earpiece)
        case speaker    // loa ngoài
        case bluetooth  // tai nghe/loa Bluetooth
        case wired      // tai nghe dây / USB
        case other
    }

    let id: String
    let name: String
    let kind: Kind
    let isActive: Bool

    var iconName: String {
        switch kind {
        case .builtin: return "iphone"
        case .speaker: return "speaker.wave.3.fill"
        case .bluetooth: return "airpods"
        case .wired: return "headphones"
        case .other: return "speaker.wave.2"
        }
    }
}

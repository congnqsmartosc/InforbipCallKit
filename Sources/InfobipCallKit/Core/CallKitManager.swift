import Foundation
import CallKit
import AVFoundation

/// Thin wrapper around `CXProvider` + `CXCallController`. It is **InfobipRTC-free**: `CallService`
/// owns the SDK and consumes this manager through the callback closures below, so all CallKit logic
/// lives here and all SDK logic stays in `CallService`.
///
/// Calls are identified by a `UUID` derived from the Infobip `callId` (`UUID(uuidString:)`), keeping
/// a stable 1:1 map between the CallKit call and the SDK `ActiveCall`.
///
/// > Note: We deliberately do **not** implement `provider(_:didActivate:)` /
/// > `provider(_:didDeactivate:)`. The Infobip RTC SDK owns and configures the `AVAudioSession`
/// > internally on `accept()` / `callWebrtc()` — there is no SDK API to hand it the CallKit-activated
/// > session, and driving the session ourselves fights the SDK. This matches Infobip's own showcase
/// > app and is consistent with `RingtonePlayer` deliberately not owning the audio session.
final class CallKitManager: NSObject {

    // MARK: Callbacks consumed by CallService (all fired on the main queue)

    /// The user answered on the system UI. Fulfill/fail `action` once the SDK call is accepted.
    var onAnswer: ((UUID, CXAnswerCallAction) -> Void)?
    /// The user ended/declined on the system UI.
    var onEnd: ((UUID, CXEndCallAction) -> Void)?
    /// The user toggled mute on the system UI.
    var onMute: ((UUID, Bool, CXSetMutedCallAction) -> Void)?
    /// An outgoing `CXStartCallAction` began (the SDK call is placed by CallService separately).
    var onStartCall: ((UUID, CXStartCallAction) -> Void)?
    /// The provider reset — tear down every active call.
    var onReset: (() -> Void)?

    private let provider: CXProvider
    private let callController = CXCallController()

    init(config: InfobipCallConfig) {
        // `init(localizedName:)` is deprecated since iOS 14 but `localizedName` is get-only, so it
        // remains the only way to set the provider's display name.
        let configuration = CXProviderConfiguration(localizedName: config.callKitDisplayName)
        configuration.supportsVideo = false
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.generic]
        if let ringtone = config.ringtoneSound {
            configuration.ringtoneSound = ringtone
        }
        if let iconData = config.callKitIconTemplateImageData {
            configuration.iconTemplateImageData = iconData
        }
        self.provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: .main)
    }

    // MARK: - Incoming

    /// Report a new incoming call to CallKit. MUST be called synchronously from the VoIP-push
    /// delegate (before its completion) or iOS terminates the app on a killed-app launch.
    func reportIncomingCall(uuid: UUID, callerName: String, completion: ((Error?) -> Void)? = nil) {
        let update = makeUpdate(callerName: callerName)
        CallLog.debug("reportIncomingCall uuid=\(uuid) name=\(callerName)", category: "CallKit")
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                CallLog.debug("reportNewIncomingCall error: \(error.localizedDescription)", category: "CallKit")
            }
            completion?(error)
        }
    }

    /// Update the caller display name once it's known (e.g. from `customData`).
    func updateCaller(uuid: UUID, name: String) {
        provider.reportCall(with: uuid, updated: makeUpdate(callerName: name))
    }

    /// Report that a call ended (remote hangup, failure, busy, unanswered…).
    func reportCallEnded(uuid: UUID, reason: CXCallEndedReason) {
        CallLog.debug("reportCallEnded uuid=\(uuid) reason=\(reason.rawValue)", category: "CallKit")
        provider.reportCall(with: uuid, endedAt: nil, reason: reason)
    }

    // MARK: - Outgoing

    /// Request an outgoing call transaction so the system shows the green pill / lock-screen controls.
    func startOutgoingCall(uuid: UUID, handle: String) {
        let cxHandle = CXHandle(type: .generic, value: handle)
        let action = CXStartCallAction(call: uuid, handle: cxHandle)
        let transaction = CXTransaction(action: action)
        request(transaction, "startOutgoingCall")
        // Tell CallKit the outgoing call has started connecting immediately.
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }

    func reportOutgoingConnecting(uuid: UUID) {
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }

    func reportOutgoingConnected(uuid: UUID) {
        provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }

    // MARK: - Helpers

    private func makeUpdate(callerName: String) -> CXCallUpdate {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: callerName)
        update.localizedCallerName = callerName
        update.hasVideo = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = false
        update.supportsDTMF = false
        return update
    }

    private func request(_ transaction: CXTransaction, _ label: String) {
        callController.request(transaction) { error in
            if let error = error {
                CallLog.debug("\(label) transaction error: \(error.localizedDescription)", category: "CallKit")
            }
        }
    }
}

// MARK: - CXProviderDelegate

extension CallKitManager: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        CallLog.debug("providerDidReset", category: "CallKit")
        onReset?()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        onAnswer?(action.callUUID, action)
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        onEnd?(action.callUUID, action)
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        onMute?(action.callUUID, action.isMuted, action)
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        onStartCall?(action.callUUID, action)
    }
}

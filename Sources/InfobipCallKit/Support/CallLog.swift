import Foundation

/// Lightweight logging facade for the framework.
///
/// Logs are compiled in only for `#if DEBUG` builds of the pod AND gated at runtime by
/// ``isEnabled`` (driven by `InfobipCallConfig.isLoggingEnabled`, default `true`). A Release
/// build of the framework emits nothing regardless of the flag, so host apps never see stray
/// logs in production.
enum CallLog {

    /// Runtime switch, set from `InfobipCallConfig.isLoggingEnabled` when the center is created.
    static var isEnabled = true

    /// Emit a debug line prefixed with `[InfobipCallKit][<category>]`. The message is an
    /// autoclosure, so string interpolation is never evaluated when logging is off.
    static func debug(_ message: @autoclosure () -> String, category: String = "InfobipCallKit") {
        #if DEBUG
        guard isEnabled else { return }
        print("[InfobipCallKit][\(category)] \(message())")
        #endif
    }
}

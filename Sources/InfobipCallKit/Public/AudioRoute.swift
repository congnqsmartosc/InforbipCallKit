import Foundation

/// A selectable audio output for the current call (public mirror of the internal `AudioRouteOption`;
/// never leaks `InfobipRTC` types). Use with ``CallSession/audioRoutes`` and
/// ``InfobipCallClient/selectAudioRoute(id:)`` to build a custom audio-route picker.
public struct AudioRoute: Equatable {
    public enum Kind: Equatable {
        case builtin    // earpiece
        case speaker    // loudspeaker
        case bluetooth
        case wired      // wired headphones / USB
        case other
    }

    /// Stable identifier to pass to ``InfobipCallClient/selectAudioRoute(id:)``.
    public let id: String
    /// Display name (already localized via `InfobipCallStrings` where applicable).
    public let name: String
    public let kind: Kind
    /// `true` when this is the currently active output.
    public let isActive: Bool

    public init(id: String, name: String, kind: Kind, isActive: Bool) {
        self.id = id
        self.name = name
        self.kind = kind
        self.isActive = isActive
    }
}

extension AudioRoute.Kind {
    init(_ kind: AudioRouteOption.Kind) {
        switch kind {
        case .builtin:   self = .builtin
        case .speaker:   self = .speaker
        case .bluetooth: self = .bluetooth
        case .wired:     self = .wired
        case .other:     self = .other
        }
    }
}

extension AudioRoute {
    /// Map the internal `AudioRouteOption` to the public value type.
    init(_ option: AudioRouteOption) {
        self.init(id: option.id, name: option.name, kind: AudioRoute.Kind(option.kind), isActive: option.isActive)
    }
}

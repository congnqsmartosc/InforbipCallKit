import Foundation

private final class BundleToken {}

extension Bundle {
    /// Bundle that actually contains InfobipCallKit's resources (xibs + `.caf`).
    ///
    /// With CocoaPods `resource_bundles`, resources are copied into a nested
    /// `InfobipCallKit.bundle` *inside* the framework, so `Bundle(for:)` does not find them.
    /// This resolves that nested bundle and falls back to the framework/module bundle
    /// (SPM or static-linkage cases).
    static let callKit: Bundle = {
        let container = Bundle(for: BundleToken.self)
        if let url = container.url(forResource: "InfobipCallKit", withExtension: "bundle"),
           let bundle = Bundle(url: url) {
            return bundle
        }
        return container
    }()
}

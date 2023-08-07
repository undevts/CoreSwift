#if CORE_SWIFT_LINK_FOUNDATION
import Foundation

extension Path {
    public init?(_ url: URL) {
        guard url.isFileURL else {
            return nil
        }
        self.init(url.relativeString)
    }
}

#endif // CORE_SWIFT_LINK_FOUNDATION

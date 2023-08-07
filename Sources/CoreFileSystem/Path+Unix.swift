#if SWIFT_PACKAGE
import CoreSwift
#endif

extension Path {
    static let preferredSeparator = ASCII.slash.rawValue

    @inlinable
    @inline(__always)
    static func parsePrefix(_ bytes: Bytes) -> Prefix? {
        nil
    }

    @inlinable
    @inline(__always)
    static func isSeparator(_ byte: UInt8) -> Bool {
        byte == ASCII.slash
    }
}

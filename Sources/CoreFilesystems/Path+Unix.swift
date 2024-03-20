#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(Linux)

#if SWIFT_PACKAGE
import CoreSwift
#endif

extension Path {
    static let preferredSeparator = ASCII.solidus.rawValue

    @inlinable
    @inline(__always)
    static func parsePrefix(_ path: OsString) -> Prefix? {
        nil
    }

    @inlinable
    @inline(__always)
    static func isSeparator(_ byte: UInt8) -> Bool {
        byte == ASCII.solidus
    }
}
#endif // os(macOS)...

#if os(Windows)

#if SWIFT_PACKAGE
import CoreSwift
import CoreSystem
#endif

extension Path {
    static let preferredSeparator = ASCII.reverseSolidus.rawValue

    @inlinable
    @inline(__always)
    static func parsePrefix(_ path: OsString) -> Prefix? {
        _parsePrefix(path)
    }

    @inlinable
    @inline(__always)
    static func isSeparator(_ byte: UInt8) -> Bool {
        byte == ASCII.solidus || byte == ASCII.reverseSolidus // '/' || '\\'
    }

    @inlinable
    @inline(__always)
    static func isVerbatimSeparator(_ byte: UInt8) -> Bool {
        byte == ASCII.reverseSolidus // '\\'
    }
}

@usableFromInline
func _parsePrefix(_ path: OsString) -> Path.Prefix? {
    // TODO: parse other
    if let drive = _parseDrive(path) {
        // C:
        return .disk(drive)
    }
    // no prefix
    return nil
}

// Parses a drive prefix, e.g. "C:" and "C:\whatever"
func _parseDrive(_ path: OsString) -> UInt8? {
    // In most DOS systems, it is not possible to have more than 26 drive letters.
    // See <https://en.wikipedia.org/wiki/Drive_letter_assignment#Common_assignments>.
    func isValidDriveLetter(drive: UInt8) -> Bool {
        ASCII(drive).isAlphabetic()
    }
    
    var i = path.bytes.makeIterator()
    switch (i.next(), i.next()) {
    case let (.some(drive), .some(ASCII.colon.rawValue)):
        return drive
    default:
        return nil
    }
}
#endif // os(Windows)

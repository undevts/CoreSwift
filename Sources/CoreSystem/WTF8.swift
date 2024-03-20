#if SWIFT_PACKAGE
import CoreSwift
#endif

@usableFromInline
struct WTF8: Hashable {
    @usableFromInline
    private(set) var bytes: Bytes

    /// Do we know that `bytes` holds a valid UTF-8 encoding? We can easily
    /// know this if we're constructed from a `String` or `&str`.
    ///
    /// It is possible for `bytes` to have valid UTF-8 without this being
    /// set, such as when we're concatenating `&Wtf8`'s and surrogates become
    /// paired, as we don't bother to rescan the entire string.
    @usableFromInline
    private(set) var isKnownUTF8: Bool

    @_transparent
    @usableFromInline
    init(bytes: Bytes, isKnownUTF8: Bool) {
        self.bytes = bytes
        self.isKnownUTF8 = isKnownUTF8
    }

    @inlinable
    @inline(__always)
    init() {
        self.init(bytes: Bytes(), isKnownUTF8: true)
    }

    @inlinable
    @inline(__always)
    init(capacity: Int) {
        self.init(bytes: Bytes(capacity: capacity), isKnownUTF8: true)
    }

    @inlinable
    @inline(__always)
    init(_ string: StaticString) {
        self.init(bytes: Bytes(string), isKnownUTF8: true)
    }
}

extension WTF8 {
    @usableFromInline
    struct CodePoint {
        @usableFromInline
        let value: UInt32

        @usableFromInline
        init(unsafe value: UInt32) {
            self.value = value
        }

        @usableFromInline
        init(_ scalar: Unicode.Scalar) {
            value = scalar.value
        }
    }
}

extension Unicode.UTF8 {
    // UTF-8 ranges and tags for encoding characters
    private static let TAG_CONT: UInt8 = 0b1000_0000
    private static let TAG_TWO_B: UInt8 = 0b1100_0000
    private static let TAG_THREE_B: UInt8 = 0b1110_0000
    private static let TAG_FOUR_B: UInt8 = 0b1111_0000
    private static let MAX_ONE_B: UInt32 = 0x80
    private static let MAX_TWO_B: UInt32 = 0x800
    private static let MAX_THREE_B: UInt32 = 0x10000

    @_alwaysEmitIntoClient
    static func width(_ code: UInt32) -> Int {
        switch code {
          case 0..<0x80: return 1
          case 0x80..<0x0800: return 2
          case 0x0800..<0x1_0000: return 3
          default: return 4
        }
    }

    @usableFromInline
    static func encodeRaw(_ code: UInt32, to bytes: inout Bytes) {
        // Copied from Rust char::encode_utf8_raw
        let size = width(code)
        bytes.reserveCapacity(bytes.count + size)
        switch size {
        case 1:
            bytes.append(UInt8(code))
        case 2:
            bytes.append(UInt8(code >> 6 & 0x1F) | TAG_TWO_B)
            bytes.append(UInt8(code & 0x3F) | TAG_CONT)
        case 3:
            bytes.append(UInt8(code >> 12 & 0x0F) | TAG_THREE_B)
            bytes.append(UInt8(code >> 6 & 0x3F) | TAG_CONT)
            bytes.append(UInt8(code & 0x3F) | TAG_CONT)
        case 4:
            bytes.append(UInt8(code >> 18 & 0x07) | TAG_FOUR_B)
            bytes.append(UInt8(code >> 12 & 0x3F) | TAG_CONT)
            bytes.append(UInt8(code >> 6 & 0x3F) | TAG_CONT)
            bytes.append(UInt8(code & 0x3F) | TAG_CONT)
        default:
            break
        }
    }
}

extension WTF8 {
    @inlinable
    @inline(__always)
    var isEmpty: Bool {
        bytes.isEmpty
    }

    @inlinable
    @inline(__always)
    var count: Int {
        bytes.count
    }

    /// This does **not** include the WTF-8 concatenation check or `isKnownUTF8` check.
    @inlinable
    @inline(__always)
    mutating func unsafeAppend(codePoint: CodePoint) {
        Unicode.UTF8.encodeRaw(codePoint.value, to: &bytes)
    }

    @inlinable
    @inline(__always)
    mutating func append(_ scalar: Unicode.Scalar) {
        unsafeAppend(codePoint: CodePoint(scalar))
    }

    @inlinable
    @inline(__always)
    mutating func append(_ byte: UInt8) {
        bytes.append(byte)
    }

    @inlinable
    @inline(__always)
    mutating func append(_ bytes: Bytes) {
        self.bytes.append(bytes)
    }

    @inlinable
    @inline(__always)
    mutating func append(_ string: OsString) {
#if os(Windows)
        bytes.append(string.content.bytes)
#else
        bytes.append(string.content)
#endif
    }

    @inlinable
    @inline(__always)
    mutating func append(_ other: WTF8) {
        bytes.append(other.bytes)
    }

    @inlinable
    @inline(__always)
    mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        bytes.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    @inline(__always)
    mutating func removeFirst() -> UInt8 {
        bytes.removeFirst()
    }

    @inlinable
    @inline(__always)
    mutating func removeFirst(_ k: Int) {
        bytes.removeFirst(k)
    }

    @inlinable
    @inline(__always)
    mutating func removeLast() -> UInt8 {
        bytes.removeLast()
    }

    @inlinable
    @inline(__always)
    mutating func removeLast(_ k: Int) {
        bytes.removeLast(k)
    }

    @usableFromInline
    static func fromWide<Iterator>(iterator: __owned Iterator, count: Int?) -> WTF8
        where Iterator: IteratorProtocol, Iterator.Element == UInt16 {
        var string = WTF8(bytes: count != nil ? Bytes(capacity: count!) : Bytes(), isKnownUTF8: true)
        var decoder = DecodeUTF16(iterator: iterator)
        switch decoder.next() {
        case .none:
            break
        case let .success(scalar):
            string.append(scalar)
        case let .failure(error):
            let surrogate = error.unpairedSurrogate()
            // Surrogates are known to be in the code point range.
            let codePoint = CodePoint(unsafe: UInt32(surrogate))
            // The string will now contain an unpaired surrogate.
            string.isKnownUTF8 = false
            // Skip the WTF-8 concatenation check,
            // surrogate pairs are already decoded by DecodeUTF16
            string.unsafeAppend(codePoint: codePoint)
            break
        }
        return string
    }
}

extension WTF8: LosslessStringConvertible {
    @inlinable
    @inline(__always)
    init(_ string: String) {
        self.init(bytes: Bytes(string), isKnownUTF8: true)
    }

    @usableFromInline
    var description: String {
        toString() ?? ""
    }

    @usableFromInline
    func toString() -> String? {
        guard isKnownUTF8 else {
            return nil
        }
        return bytes.toString()
    }

    @usableFromInline
    func toStringLossy() -> String {
        bytes.toString()
    }

    @inlinable
    @inline(__always)
    mutating func asciiLowercase() {
        bytes.asciiLowercase()
    }

    @inlinable
    @inline(__always)
    func asciiLowercased() -> WTF8 {
        WTF8(bytes: bytes.asciiLowercased(), isKnownUTF8: false)
    }

    @inlinable
    @inline(__always)
    mutating func asciiUppercase() {
        bytes.asciiUppercase()
    }

    @inlinable
    @inline(__always)
    func asciiUppercased() -> WTF8 {
        WTF8(bytes: bytes.asciiUppercased(), isKnownUTF8: false)
    }

    @inlinable
    @inline(__always)
    mutating func withMutableBytes<T>(_ method: (inout Bytes) throws -> T) rethrows -> T {
return try method(&bytes)
    }
}

struct DecodeUTF16Error: Error {
    let code: UInt16

    func unpairedSurrogate() -> UInt16 {
        code
    }
}

struct DecodeUTF16<Iterator> where Iterator: IteratorProtocol, Iterator.Element == UInt16 {
    var iterator: Iterator
    var buffer: Optional<UInt16>

    init(iterator: __owned Iterator) {
        self.iterator = iterator
        buffer = nil
    }
}

extension DecodeUTF16: IteratorProtocol {
    typealias Element = Result<Unicode.Scalar, DecodeUTF16Error>

    mutating func next() -> Element? {
        // TODO: Swift 5.9, replace with if expression.
        let u: UInt16
        if let t = buffer.take() {
            u = t
        } else if let n = iterator.next() {
            u = n
        } else {
            return nil
        }
        if !Unicode.UTF16.isSurrogate(u) {
            // SAFETY: not a surrogate
            return .success(Unicode.Scalar(u)!)
        }
        if u >= 0xDC00 {
            // a trailing surrogate
            return .failure(DecodeUTF16Error(code: u))
        }
        guard let u2 = iterator.next() else {
            return .failure(DecodeUTF16Error(code: u))
        }
        if u2 < 0xDC00 || u2 > 0xDFFF {
            // not a trailing surrogate so we're not a valid
            // surrogate pair, so rewind to redecode u2 next time.
            buffer = u2
            return .failure(DecodeUTF16Error(code: u))
        }
        // all ok, so lets decode it.
        let c = (UInt32(u & 0x3ff) << 10 | UInt32(u2 & 0x3ff)) + 0x1_0000
        // SAFETY: we checked that it's a legal unicode value
        return .success(Unicode.Scalar(c)!)
    }
}

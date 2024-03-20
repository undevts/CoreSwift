#if SWIFT_PACKAGE
import CoreSwift
#endif

@frozen
public struct OsString: Hashable {
#if os(Windows)
    @usableFromInline
    typealias Content = WTF8
#else
    @usableFromInline
    typealias Content = Bytes
#endif

    @usableFromInline
    var content: Content

    @_transparent
    @usableFromInline
    init(content: Content) {
        self.content = content
    }

    @inlinable
    public var isEmpty: Bool {
        content.isEmpty
    }

    /// Gets the underlying byte representation.
    ///
    /// Note: it is *crucial* that this API is not externally public, to avoid
    /// revealing the internal, platform-specific encodings.
    @inlinable
    public var bytes: Bytes {
#if os(Windows)
        content.bytes
#else
        content
#endif
    }

    /// Returns the length of this ``OsString``.
    ///
    /// Note that this does **not** return the number of bytes in the string in
    /// OS string form.
    ///
    /// The length returned is that of the underlying storage used by ``OsString``.
    @inlinable
    public var count: Int {
#if os(Windows)
        content.count
#else
        content.count
#endif
    }
}

extension OsString: ExpressibleByStringLiteral {
    @inlinable
    public init(stringLiteral value: StaticString) {
#if os(Windows)
        self.content = WTF8(value)
#else
        self.content = Bytes(value)
#endif
    }

    @inlinable
    public init<S>(_ value: S) where S: StringProtocol {
#if os(Windows)
        self.content = WTF8(bytes: Bytes(value), isKnownUTF8: true)
#else
        self.content = Bytes(value)
#endif
    }
}

extension OsString: LosslessStringConvertible {
    /// Creates a new instance from the given string.
    @inlinable
    public init(_ string: String) {
#if os(Windows)
        self.content = WTF8(string)
#else
        self.content = Bytes(string)
#endif
    }

    @inlinable
    public var description: String {
        string
    }
}

extension OsString {
    /// Creates a new, empty ``OsString``.
    ///
    /// ```swift
    /// import CoreSwift
    /// 
    /// let string = OsString()
    /// ```
    @inlinable
    public init() {
#if os(Windows)
        self.content = WTF8()
#else
        self.content = Bytes()
#endif
    }

    @inlinable
    public init(unchecked bytes: Bytes, utf8: Bool = true) {
#if os(Windows)
        self.content = WTF8(bytes: bytes, isKnownUTF8: utf8)
#else
        self.content = bytes
#endif
    }

    @inlinable
    public var string: String {
#if os(Windows)
        content.toStringLossy()
#else
        content.toString()
#endif
    }

    /// Returns a copy of this string where each character is mapped to its
    /// ASCII lower case equivalent.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To lowercase the value in-place, use ``asciiLowercase()``.
    @inlinable
    @inline(__always)
    public func asciiLowercased() -> OsString {
        OsString(content: content.asciiLowercased())
    }

    /// Converts this string to its ASCII lower case equivalent in-place.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To return a new lowercased value without modifying the existing one, use
    /// ``asciiLowercased()``.
    @inlinable
    @inline(__always)
    public mutating func asciiLowercase() {
        content.asciiLowercase()
    }

    /// Returns a copy of this string where each character is mapped to its
    /// ASCII upper case equivalent.
    ///
    /// ASCII letters 'a' to 'z' are mapped to 'A' to 'Z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To uppercase the value in-place, use ``asciiUppercase()``.
    @inlinable
    @inline(__always)
    public func asciiUppercased() -> OsString {
        OsString(content: content.asciiUppercased())
    }

    /// Converts this string to its ASCII upper case equivalent in-place.
    ///
    /// ASCII letters 'a' to 'z' are mapped to 'A' to 'Z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To return a new uppercased value without modifying the existing one, use
    /// ``asciiUppercased()``.
    @inlinable
    @inline(__always)
    public mutating func asciiUppercase() {
        content.asciiUppercase()
    }
}

extension OsString {
    @inlinable
    public mutating func withMutableBytes<T>(_ method: (inout Bytes) throws -> T) rethrows -> T {
#if os(Windows)
        return try content.withMutableBytes(method)
#else
        return try method(&content)
#endif
    }

    @inlinable
    public mutating func append(_ byte: UInt8) {
        content.append(byte)
    }

    @inlinable
    public mutating func append(_ bytes: Bytes) {
        content.append(bytes)
    }

    @inlinable
    public mutating func append(_ string: OsString) {
        content.append(string.content)
    }

    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        content.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public mutating func removeFirst() -> UInt8 {
        content.removeFirst()
    }

    @inlinable
    public mutating func removeFirst(_ k: Int) {
        content.removeFirst(k)
    }

    @inlinable
    public mutating func removeLast() -> UInt8 {
        content.removeLast()
    }

    @inlinable
    public mutating func removeLast(_ k: Int) {
        content.removeLast(k)
    }
}

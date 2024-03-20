// For strlen
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif os(Windows)
import ucrt
#elseif canImport(Glibc)
import Glibc
#endif

#if CORE_SWIFT_LINK_FOUNDATION
import Foundation
#endif

#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

extension Bytes: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: UInt8...) {
        let storage = elements.withUnsafeBytes(Storage.from)
        self.init(storage: storage)
    }
}

extension Bytes {
    @inlinable
    public init(_ array: [UInt8]) {
        let storage = array.withUnsafeBytes(Storage.from)
        self.init(storage: storage)
    }

    @inlinable
    public init(chars array: [Int8]) {
        let storage = array.withUnsafeBytes(Storage.from)
        self.init(storage: storage)
    }

    @inlinable
    public init(_ string: String) {
        let storage = Bytes.storage(from: string)
        self.init(storage: storage)
    }

    @inlinable
    public init(_ string: StaticString) {
        let storage = string.withUTF8Buffer(Storage.from)
        self.init(storage: storage)
    }

    @inlinable
    public init<S>(_ string: S) where S: StringProtocol {
        let storage = Bytes._storage(from: string)
        self.init(storage: storage)
    }

    @inlinable
    public func toArray(capacity: Int? = nil) -> [UInt8] {
        let size = storage.count
        return Array<UInt8>(unsafeUninitializedCapacity: Swift.max(capacity ?? 0, size)) { buffer, count in
            buffer.baseAddress?.update(from: storage.start, count: size)
            count = size
        }
    }

    @inlinable
    public func toContiguousArray(capacity: Int? = nil) -> ContiguousArray<UInt8> {
        let size = storage.count
        return ContiguousArray<UInt8>(unsafeUninitializedCapacity: Swift.max(capacity ?? 0, size)) { buffer, count in
            buffer.baseAddress?.update(from: storage.start, count: size)
            count = size
        }
    }

    @inline(__always)
    @usableFromInline
    func isCString() -> Bool {
        withExtendedLifetime(storage) {
            cci_unrolled_find_uint8(storage.start, storage.count, 0)
        }
    }

    public func toString() -> String {
        if isCString() {
            return String(cString: storage.start)
        }
        var array = toArray(capacity: count + 1)
        array.append(0)
        return String(cString: array)
    }
    
    public mutating func asString() -> String {
        if isCString() {
            return String(cString: storage.start)
        }
        append(0)
        return String(cString: storage.start)
    }

#if CORE_SWIFT_LINK_FOUNDATION
    public func toString(encoding: String.Encoding) -> String? {
        let start = UnsafeRawPointer(storage.start)
                .assumingMemoryBound(to: CChar.self)
        if isCString() {
            return String(cString: start, encoding: encoding)
        }
        let size = storage.count
        let array = Array<Int8>(unsafeUninitializedCapacity: size + 1) { buffer, count in
            guard let base = buffer.baseAddress else {
                return
            }
            base.update(from: start, count: size)
            base.advanced(by: size)
                .initialize(to: 0)
            count = size + 1
        }
        return String(cString: array, encoding: encoding)
    }
#endif

    @inline(__always)
    @usableFromInline
    static func storage(from string: String) -> Storage {
        _storage(from: string)
    }

    @inline(__always)
    @usableFromInline
    static func _storage<S>(from string: S) -> Storage where S: StringProtocol {
        if let storage = Storage.from(string.utf8) {
            return storage
        }
        return string.withCString { pointer -> Storage in
            let start = UnsafeRawPointer(pointer)
                .assumingMemoryBound(to: UInt8.self)
            let buffer = UnsafeBufferPointer(start: start, count: strlen(pointer))
            return Storage.from(buffer)
        }
    }
}

extension Bytes {
    /// Returns a `Bytes` containing a copy of this bytes where each byte
    /// is mapped to its ASCII upper case equivalent.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To uppercase the value in-place, use ``asciiUppercase()``.
    @inlinable
    public func asciiUppercased() -> Bytes {
        var result = self
        result.asciiUppercase()
        return result
    }

    /// Converts this bytes to its ASCII upper case equivalent in-place.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To return a new uppercased value without modifying the existing one, use
    /// ``asciiUppercased()``.
    public mutating func asciiUppercase() {
        if _slowPath(storage.start == Bytes.null) {
            return
        }
        _reserveCapacity(capacity, unique: true)
        var c = storage.start
        let n = storage.current
        while c < n {
            c.initialize(to: c.pointee.asciiUppercased())
            c += 1
        }
    }

    /// Returns a `Bytes` containing a copy of this bytes where each byte
    /// is mapped to its ASCII lower case equivalent.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To lowercase the value in-place, use ``asciiLowercase()``.
    @inlinable
    public func asciiLowercased() -> Bytes {
        var result = self
        result.asciiLowercase()
        return result
    }

    /// Converts this bytes to its ASCII lower case equivalent in-place.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To return a new lowercased value without modifying the existing one, use
    /// ``asciiLowercased()``.
    public mutating func asciiLowercase() {
        if _slowPath(storage.start == Bytes.null) {
            return
        }
        _reserveCapacity(capacity, unique: true)
        var c = storage.start
        let n = storage.current
        while c < n {
            c.initialize(to: c.pointee.asciiLowercased())
            c += 1
        }
    }
}

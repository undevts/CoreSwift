// For strlen
#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

#if CORE_SWIFT_LINK_FOUNDATION
import Foundation
#endif

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

#if CORE_SWIFT_LINK_FOUNDATION || canImport(Glibc)
    @inlinable
#endif
    public func toString() -> String? {
#if CORE_SWIFT_LINK_FOUNDATION
        return String(data: toData(), encoding: .utf8)
#else
        var array = toArray(capacity: count + 1)
        array.append(0)
        return String(cString: array)
#endif
    }

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

extension Bytes: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: UInt8...) {
        let storage = elements.withUnsafeBytes(Storage.from)
        self.init(storage: storage)
    }
}

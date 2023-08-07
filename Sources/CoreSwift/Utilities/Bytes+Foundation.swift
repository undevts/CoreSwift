#if CORE_SWIFT_LINK_FOUNDATION
import Foundation

extension Bytes {
    @inlinable
    public init(_ data: Data) {
        let storage = data.withUnsafeBytes(Storage.from)
        self.init(storage: storage)
    }

    @inlinable
    public func toData() -> Data {
        Data(bytes: UnsafeMutableRawPointer(storage.start),
            count: storage.count)
    }

    @inlinable
    public mutating func releaseAsData() -> Data {
        if isStorageUnique() {
            let (start, count) = release()
            return Data(bytesNoCopy: UnsafeMutableRawPointer(start),
                count: count, deallocator: .free)
        } else {
            return toData()
        }
    }
}

#endif // CORE_SWIFT_LINK_FOUNDATION

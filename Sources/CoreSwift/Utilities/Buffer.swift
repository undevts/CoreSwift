#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

@frozen
public struct Buffer<T> {
    public typealias Element = T
    public typealias SubSequence = Buffer<T>

    @usableFromInline
    typealias Pointer = UnsafeMutablePointer<T>

    @usableFromInline
    private(set) var storage: Storage

    @_transparent
    @usableFromInline
    init(storage: Storage) {
        self.storage = storage
    }

    @inline(__always)
    @usableFromInline
    static var null: UnsafeMutablePointer<T> {
        UnsafeMutableRawPointer(cci_null_bytes())
            .assumingMemoryBound(to: T.self)
    }
}

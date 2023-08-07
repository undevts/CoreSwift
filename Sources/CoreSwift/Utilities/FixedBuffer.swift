#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

public protocol FixedBuffer {
    var capacity: Int { get }

    mutating func start() -> UnsafeMutablePointer<UInt8>
    mutating func end() -> UnsafeMutablePointer<UInt8>
}

extension FixedBuffer {
    @inlinable
    public mutating func buffer() -> UnsafeMutableBufferPointer<UInt8> {
        let start = start()
        return UnsafeMutableBufferPointer(start: start, count: end() - start)
    }
}

@frozen
public struct FixedBuffer32: FixedBuffer {
    @usableFromInline
    var buffer: cci_buffer_32

    @inlinable
    public init() {
        buffer = cci_buffer_32()
    }

    @inlinable
    public var capacity: Int {
        buffer.capacity
    }

    @inlinable
    public mutating func start() -> UnsafeMutablePointer<UInt8> {
        buffer.start()
    }

    @inlinable
    public mutating func end() -> UnsafeMutablePointer<UInt8> {
        buffer.end()
    }
}
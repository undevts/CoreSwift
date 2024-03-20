#if SWIFT_PACKAGE
import CoreSwift
#endif

public protocol Writer {
    mutating func write(buffer: UnsafeBufferPointer<UInt8>) -> IOResult<UInt>
    mutating func flush() -> IOResult<Void>

    mutating func write(buffer: Bytes) -> IOResult<UInt>
    mutating func writeAll(buffer: UnsafeBufferPointer<UInt8>) -> IOResult<Void>
}

extension Writer {
    public mutating func write(buffer: Bytes) -> IOResult<UInt> {
        buffer.withUnsafeBuffer { pointer -> IOResult<UInt> in
            write(buffer: pointer)
        }
    }

    public mutating func writeAll(buffer: UnsafeBufferPointer<UInt8>) -> IOResult<Void> {
        IODefault.writeAll(&self, buffer: buffer)
    }
}
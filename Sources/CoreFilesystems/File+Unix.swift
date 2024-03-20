#if !os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#endif

#if SWIFT_PACKAGE
import CoreSwift
import CoreIOKit
#endif

extension File {
    init(raw fd: Int32) {
        content = FileDescriptor(fd)
    }
}

extension File {
    @usableFromInline
    var requiredCapacity: Int {
        let size: UInt64 = metadata().map(\.size).unwrap(or: 0)
        let position: UInt64 = streamPosition().unwrap(or: 0)
        return Int(size - position)
    }

    var raw: CInt {
        content.raw
    }

    public func metadata() -> IOResult<FileMetadata> {
        Filesystem._fstat(raw)
    }
}

extension File: Seekable {
    public func seek(position: SeekFrom) -> IOResult<UInt64> {
        let (whence, offset) = position.flags()
        return IO.call { () -> off_t in
            lseek(raw, offset, whence)
        }.map(UInt64.init(_:))
    }

    public func rewind() -> IOResult<Void> {
        seek(position: .start(0))
            .map(Function.nothing)
    }

    public func streamSize() -> IOResult<UInt64> {
        streamPosition().flatMap { old -> IOResult<UInt64> in
            seek(position: .end(0)).flatMap { count -> IOResult<UInt64> in
                // Avoid seeking a third time when we were already at the end of the
                // stream. The branch is usually way cheaper than a seek operation.
                old != count ? seek(position: .start(old)) : .success(count)
            }
        }
    }

    public func streamPosition() -> IOResult<UInt64> {
        seek(position: .current(0))
    }
}

extension File: Reader {
    @inlinable
    public func read(buffer: UnsafeMutableBufferPointer<UInt8>) -> IOResult<Int> {
       content.read(buffer: buffer)
    }

    @inlinable
    public func read(buffer: inout Bytes) -> IOResult<Int> {
       content.read(buffer: &buffer)
    }

    @inlinable
    public func read(into buffer: inout Bytes) -> IOResult<Int> {
       content.read(into: &buffer)
    }

    @inlinable
    public func readAll(buffer: inout Bytes) -> IOResult<Int> {
        let size = requiredCapacity
        buffer.reserveCapacity(size)
        var temp = self
        return IODefault.readAll(&temp, buffer: &buffer, hint: size)
    }
}

extension File: Writer {
    public func write(buffer: UnsafeBufferPointer<UInt8>) -> IOResult<UInt> {
       guard buffer.count > 0, let base = buffer.baseAddress else {
           return .success(0)
       }
       let count = buffer.count
       return IO.call { () -> Int in
           Darwin.write(raw, base, min(count, IO.readLimit))
       }.map(UInt.init)
    }

    public func write(buffer: Bytes) -> IOResult<UInt> {
       buffer.withUnsafeBuffer { pointer -> IOResult<UInt> in
           write(buffer: pointer)
       }
    }

    public func flush() -> IOResult<Void> {
       .success(())
    }

    public func writeAll(buffer: UnsafeBufferPointer<UInt8>) -> IOResult<()> {
       var temp = self
       return IODefault.writeAll(&temp, buffer: buffer)
    }
}

#endif // !os(Windows)

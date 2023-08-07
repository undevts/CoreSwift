#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

#if SWIFT_PACKAGE
import CoreSwift
import CoreIOKit
#endif

public final class File {
    @usableFromInline
    var descriptor: FileDescriptor

    @inlinable
    @inline(__always)
    init(descriptor: FileDescriptor) {
        self.descriptor = descriptor
    }

    convenience init(raw: Int32) {
        self.init(descriptor: FileDescriptor(rawValue: raw))
    }

    deinit {
        _close()
    }

    @inlinable
    @inline(__always)
    var raw: Int32 {
        descriptor.rawValue
    }

    @usableFromInline
    var requiredCapacity: Int {
        let size: UInt64 = metadata().map(\.size).unwrap(or: 0)
        let position: UInt64 = streamPosition().unwrap(or: 0)
        return Int(size - position)
    }

    func _close() {
        close(descriptor.rawValue)
        descriptor.rawValue = -1
    }

    public func metadata() -> IOResult<FileMetadata> {
        Filesystem._fstat(raw)
    }

    @usableFromInline
    static func _open(_ path: Path, flags: Int32) -> IOResult<File> {
        IO.call { () -> Int32 in
            path.withCString { pointer -> Int32 in
                Darwin.open(pointer, flags)
            }
        }.map(File.init(raw:))
    }

    @inlinable
    public static func open(_ path: Path, option: OpenOption? = nil) -> IOResult<File> {
        let flags: Int32
        switch option?.flags {
        case .none:
            flags = OpenOption._read
        case let .success(value):
            flags = value
        case let .failure(error):
            return .failure(error)
        }
        return _open(path, flags: flags)
    }

    @inlinable
    public static func create(_ path: Path) -> IOResult<File> {
        _open(path, flags: OpenOption._create)
    }

    @inlinable
    public static func createNew(_ path: Path) -> IOResult<File> {
        _open(path, flags: OpenOption._createNew)
    }
}

extension File: Seekable {
    public func seek(position: SeekFrom) -> IOResult<UInt64> {
        let (whence, offset) = position.flags()
        return IO.call { () -> off_t in
            lseek(raw, offset, whence)
        }.map(UInt64.init)
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
        descriptor.read(buffer: buffer)
    }

    @inlinable
    public func read(buffer: inout Bytes) -> IOResult<Int> {
        descriptor.read(buffer: &buffer)
    }

    @inlinable
    public func read(into buffer: inout Bytes) -> IOResult<Int> {
        descriptor.read(into: &buffer)
    }

    @inlinable
    public func readToEnd(buffer: inout Bytes) -> IOResult<Int> {
        buffer.reserveCapacity(requiredCapacity)
        var temp = self
        return IODefault.readToEnd(&temp, buffer: &buffer)
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

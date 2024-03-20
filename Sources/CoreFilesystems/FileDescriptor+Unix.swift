#if !os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#endif

#if SWIFT_PACKAGE
import CoreIOKit
#endif

extension FileDescriptor {
    @usableFromInline
    static func open(_ path: Path, option: OpenOption.Content) -> IOResult<File> {
        option.flags().flatMap { flags -> IOResult<File> in 
            IO.call { () -> Int32 in
                path.withCString { pointer -> Int32 in
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                    Darwin.open(pointer, flags, option.mode)
#else
                    Glibc.open(pointer, option.flags, option.mode)
#endif
                }
            }.map(File.init(raw:))
        }
    }

    @inlinable
    static func open(_ path: Path) -> IOResult<File> {
        var option = OpenOption.Content()
        option.read = true
        return FileDescriptor.open(path, option: option)
    }

    @inlinable
    static func create(_ path: Path) -> IOResult<File> {
        var option = OpenOption.Content()
        option.write = true
        option.create = true
        option.truncate = true
        return FileDescriptor.open(path, option: option)
    }

    @inlinable
    static func createNew(_ path: Path) -> IOResult<File> {
        var option = OpenOption.Content()
        option.read = true
        option.write = true
        option.createNew = true
        return FileDescriptor.open(path, option: option)
    }

    @usableFromInline
    func read(buffer: UnsafeMutableBufferPointer<UInt8>) -> IOResult<Int> {
        IO.call { () -> Int in
            guard let base = buffer.baseAddress else {
                return 0
            }
            let capacity = buffer.count
            return Darwin.read(raw, UnsafeMutableRawPointer(base),
                min(capacity, IO.readLimit))
        }
    }

    @usableFromInline
    func read(buffer: inout Bytes) -> IOResult<Int> {
        IO.call { () -> Int in
            let capacity = buffer.capacity
            let size = buffer.withUnsafeMutableStorage { (start, _, current) -> Int in
                let size = Darwin.read(raw, UnsafeMutableRawPointer(start),
                    min(capacity, IO.readLimit))
                current = start + size
                return size
            }
            return size ?? 0
        }
    }

    @usableFromInline
    func read(into buffer: inout Bytes) -> IOResult<Int> {
        IO.call { () -> Int in
            let size = buffer.withUnsafeMutableStorage { (start, end, current) -> Int in
                let capacity = end - current
                let size = Darwin.read(raw, UnsafeMutableRawPointer(start),
                    min(capacity, IO.readLimit))
                current += size
                return size
            }
            return size ?? 0
        }
    }
}
#endif // !os(Windows)

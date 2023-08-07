#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

@frozen
public struct FileDescriptor: RawRepresentable {
    public var rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}

extension FileDescriptor {
    public func read(buffer: UnsafeMutableBufferPointer<UInt8>) -> IOResult<Int> {
        IO.call { () -> Int in
            guard let base = buffer.baseAddress else {
                return 0
            }
            let capacity = buffer.count
            return Darwin.read(rawValue, UnsafeMutableRawPointer(base),
                min(capacity, IO.readLimit))
        }
    }

    public func read(buffer: inout Bytes) -> IOResult<Int> {
        IO.call { () -> Int in
            let capacity = buffer.capacity
            let size = buffer.withUnsafeMutableStorage { (start, end, current) -> Int in
                let size = Darwin.read(rawValue, UnsafeMutableRawPointer(start),
                    min(capacity, IO.readLimit))
                current = start + size
                return size
            }
            return size ?? 0
        }
    }

    public func read(into buffer: inout Bytes) -> IOResult<Int> {
        IO.call { () -> Int in
            let size = buffer.withUnsafeMutableStorage { (start, end, current) -> Int in
                let capacity = end - current
                let size = Darwin.read(rawValue, UnsafeMutableRawPointer(start),
                    min(capacity, IO.readLimit))
                current += size
                return size
            }
            return size ?? 0
        }
    }
}

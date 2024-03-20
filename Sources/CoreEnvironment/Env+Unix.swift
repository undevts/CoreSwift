#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || canImport(Glibc)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#endif

#if SWIFT_PACKAGE
import CoreIOKit
import CoreFilesystem
#endif

@usableFromInline
func _currentDirectory() -> IOResult<Path> {
    var buffer = Bytes(capacity: 512)
    while true {
        let capacity = buffer.capacity
        var size = 0
        let result = buffer.withUnsafeMutableStorage { (start, _, current) -> IOResult<Void>? in
            if getcwd(start, capacity) != nil {
                size = strnlen(start, capacity)
                current += size
                return .success(())
            }
            let error = IOError.lastOSError()
            if error.rawOsError != ERANGE {
                return .failure(error)
            }
            return nil
        }
        // result: IOResult<Void>??
        if let result = result.flatMap(Function.identity) {
            // TODO: shrink_to_fit
            buffer = buffer[..<(buffer.startIndex + size)]
            return result.map { _ -> Path in
                // TODO: Use OsString
                Path(buffer.toString())
            }
        }
        // Trigger the internal buffer resizing logic of `Bytes` by requiring
        // more space than the current capacity.
        buffer.reserveCapacity(capacity * 2)
    }
}

#endif // os(macOS)...

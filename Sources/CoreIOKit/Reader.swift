#if SWIFT_PACKAGE
import CoreSwift
#endif

/// The `Reader` protocol allows for reading bytes from a source.
///
/// Implementors of the `Reader` protocol are called 'readers'.
///
/// Readers are defined by one required method, ``read(buffer:)-9n988``.
/// Each call to ``read(buffer:)-9n988`` will attempt to pull bytes from this
/// source into a provided buffer. A number of other methods are implemented
/// in terms of ``read(buffer:)-9n988`` giving implementors a number of ways
/// to read bytes while only needing to implement a single method.
///
/// Readers are intended to be composable with one another. Many implementors
/// throughout [`std::io`] take and provide types which implement the `Reader`
/// protocol.
///
/// Please note that each call to ``read(buffer:)-9n988`` may involve a system
/// call, and therefore, using something that implements [`BufRead`], such as
/// [`BufReader`], will be more efficient.
public protocol Reader {
    mutating func read(buffer: UnsafeMutableBufferPointer<UInt8>) -> IOResult<Int>

    mutating func read(buffer: inout Bytes) -> IOResult<Int>
    mutating func read(into buffer: inout Bytes) -> IOResult<Int>
    mutating func readToEnd(buffer: inout Bytes) -> IOResult<Int>
}

extension Reader {
    public mutating func read(buffer: inout Bytes) -> IOResult<Int> {
        buffer.withUnsafeMutableStorage { (start, end, current) -> IOResult<Int> in
            let temp = UnsafeMutableBufferPointer<UInt8>(start: start, count: end - start)
            let size = read(buffer: temp)
            current = start + size.unwrap(or: 0)
            return size
        } ?? .success(0)
    }

    public mutating func read(into buffer: inout Bytes) -> IOResult<Int> {
        buffer.withUnsafeMutableStorage { (start, end, current) -> IOResult<Int> in
            let temp = UnsafeMutableBufferPointer<UInt8>(start: current, count: end - current)
            let size = read(buffer: temp)
            current += size.unwrap(or: 0)
            return size
        } ?? .success(0)
    }

    public mutating func readToEnd(buffer: inout Bytes) -> IOResult<Int> {
        IODefault.readToEnd(&self, buffer: &buffer)
    }
}

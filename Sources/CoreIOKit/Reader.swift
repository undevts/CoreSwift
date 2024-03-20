#if SWIFT_PACKAGE
import CoreSwift
#endif

/// The `Reader` protocol allows for reading bytes from a source.
///
/// Implementors of the `Reader` protocol are called 'readers'.
///
/// Readers are defined by one required method, ``read(buffer:)``.
/// Each call to ``read(buffer:)`` will attempt to pull bytes from this
/// source into a provided buffer. A number of other methods are implemented
/// in terms of ``read(buffer:)`` giving implementors a number of ways
/// to read bytes while only needing to implement a single method.
///
/// Readers are intended to be composable with one another. Many implementors
/// throughout `CoreIOKit` take and provide types which implement the `Reader`
/// protocol.
///
/// Please note that each call to ``read(buffer:)`` may involve a system
/// call, and therefore, using something that implements ``BufferReader``, such as
/// ``BufferReader``, will be more efficient.
public protocol Reader {
    /// Pull some bytes from this source into the specified buffer, returning
    /// how many bytes were read.
    ///
    /// This function does not provide any guarantees about whether it blocks
    /// waiting for data, but if an object needs to block for a read and cannot,
    /// it will typically signal this via an `.failure` return value.
    ///
    /// If the return value of this method is `.success(n)`, then implementations must
    /// guarantee that `0 <= n <= buffer.count`. A nonzero `n` value indicates
    /// that the buffer `buffer` has been filled in with `n` bytes of data from this
    /// source. If `n` is `0`, then it can indicate one of two scenarios:
    ///
    /// 1. This reader has reached its "end of file" and will likely no longer
    ///    be able to produce bytes. Note that this does not mean that the
    ///    reader will *always* no longer be able to produce bytes. As an example,
    ///    on Linux, this method will call the `recv` syscall for a [`TcpStream`],
    ///    where returning zero indicates the connection was shut down correctly. While
    ///    for `File`, it is possible to reach the end of file and get zero as result,
    ///    but if more data is appended to the file, future calls to `read` will return
    ///    more data.
    /// 2. The buffer specified was 0 bytes in length.
    ///
    /// It is not an error if the returned value `n` is smaller than the buffer size,
    /// even when the reader is not at the end of the stream yet.
    /// This may happen for example because fewer bytes are actually available right now
    /// (e. g. being close to end-of-file) or because read() was interrupted by a signal.
    ///
    /// As this trait is safe to implement, callers in unsafe code cannot rely on
    /// `n <= buffer.count` for safety.
    /// Extra care needs to be taken when `unsafe` functions are used to access the read bytes.
    /// Callers have to ensure that no unchecked out-of-bounds accesses are possible even if
    /// `n > buffer.count`.
    ///
    /// No guarantees are provided about the contents of `buffer` when this
    /// function is called, so implementations cannot rely on any property of the
    /// contents of `buffer` being true. It is recommended that *implementations*
    /// only write data to `buffer` instead of reading its contents.
    ///
    /// Correspondingly, however, *callers* of this method in unsafe code must not assume
    /// any guarantees about how the implementation uses `buffer`. The trait is safe to implement,
    /// so it is possible that the code that's supposed to write to the buffer might also read
    /// from it. It is your responsibility to make sure that `buffer` is initialized
    /// before calling `read`. Calling `read` with an uninitialized `buffer` (of the kind one
    /// obtains via `UnsafeMutablePointer.allocate(capacity:)`) is not safe, and
    /// can lead to undefined behavior.
    ///
    /// - Example: `File`s implement ``Reader``:
    ///
    /// ```swift
    /// let file = File.open("foo.txt")
    /// let buffer = UnsafeMutableBufferPointer
    /// file.read(buffer: buffer)
    /// ```
    mutating func read(buffer: UnsafeMutableBufferPointer<UInt8>) -> IOResult<Int>

    mutating func read(into buffer: inout Bytes) -> IOResult<Int>
    mutating func readAll(into buffer: inout Bytes) -> IOResult<Int>
    mutating func readAll(into string: inout String) -> IOResult<Int>
}

extension Reader {
    public mutating func read(into buffer: inout Bytes) -> IOResult<Int> {
        buffer.withUnsafeMutableStorage { (start, end, current) -> IOResult<Int> in
            let temp = UnsafeMutableBufferPointer<UInt8>(start: current, count: end - current)
            let size = read(buffer: temp)
            current += size.unwrap(or: 0)
            return size
        } ?? .success(0)
    }

    public mutating func readAll(into buffer: inout Bytes) -> IOResult<Int> {
        IODefault.readAll(&self, buffer: &buffer, hint: nil)
    }

    public mutating func readAll(into string: inout String) -> IOResult<Int> {
        var bytes = Bytes()
        return readAll(into: &bytes).map { size in
            string.append(bytes.toString())
            return size
        }
    }
}

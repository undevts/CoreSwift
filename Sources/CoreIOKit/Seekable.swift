#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

#if SWIFT_PACKAGE
import CoreSwift
#endif

/// Enumeration of possible methods to seek within an I/O object.
///
/// It is used by the ``Seekable`` protocol.
@frozen
public enum SeekFrom {
    /// Sets the offset to the provided number of bytes.
    case start(UInt64)
    /// Sets the offset to the size of this object plus the specified number of bytes.
    ///
    /// It is possible to seek beyond the end of an object, but it’s an error to seek before byte 0.
    case end(Int64)
    /// Sets the offset to the current position plus the specified number of bytes.
    ///
    /// It is possible to seek beyond the end of an object, but it’s an error to seek before byte 0.
    case current(Int64)
}

extension SeekFrom {
    @inlinable
    @inline(__always)
    public func flags() -> (Int32, Int64) {
        switch self {
        case let .start(value):
            return (SEEK_SET, Int64(value))
        case let .end(value):
            return (SEEK_END, value)
        case let .current(value):
            return (SEEK_CUR, value)
        }
    }
}

/// The `Seek` trait provides a cursor which can be moved within a stream of
/// bytes.
///
/// The stream typically has a fixed size, allowing seeking relative to either
/// end or the current offset.
public protocol Seekable {
    /// Seek to an offset, in bytes, in a stream.
    ///
    /// A seek beyond the end of a stream is allowed, but behavior is defined
    /// by the implementation.
    ///
    /// If the seek operation completed successfully,
    /// this method returns the new position from the start of the stream.
    /// That position can be used later with [`SeekFrom::Start`].
    ///
    /// # Errors
    ///
    /// Seeking can fail, for example because it might involve flushing a buffer.
    ///
    /// Seeking to a negative offset is considered an error.
    mutating func seek(position: SeekFrom) -> IOResult<UInt64>

    /// Rewind to the beginning of a stream.
    ///
    /// This is a convenience method, equivalent to `seek(SeekFrom::Start(0))`.
    ///
    /// # Errors
    ///
    /// Rewinding can fail, for example because it might involve flushing a buffer.
    mutating func rewind() -> IOResult<Void>

    /// Returns the length of this stream (in bytes).
    ///
    /// This method is implemented using up to three seek operations. If this
    /// method returns successfully, the seek position is unchanged (i.e. the
    /// position before calling this method is the same as afterwards).
    /// However, if this method returns an error, the seek position is
    /// unspecified.
    ///
    /// If you need to obtain the length of *many* streams and you don't care
    /// about the seek position afterwards, you can reduce the number of seek
    /// operations by simply calling `seek(SeekFrom::End(0))` and using its
    /// return value (it is also the stream length).
    ///
    /// Note that length of a stream can change over time (for example, when
    /// data is appended to a file). So calling this method multiple times does
    /// not necessarily return the same length each time.
    mutating func streamSize() -> IOResult<UInt64>

    /// Returns the current seek position from the start of the stream.
    ///
    /// This is equivalent to `self.seek(SeekFrom::Current(0))`.
    mutating func streamPosition() -> IOResult<UInt64>
}

extension Seekable {
    public mutating func rewind() -> IOResult<Void> {
        seek(position: .start(0))
            .map(Function.nothing)
    }

    public mutating func streamSize() -> IOResult<UInt64> {
        streamPosition().flatMap { old -> IOResult<UInt64> in
            seek(position: .end(0)).flatMap { count -> IOResult<UInt64> in
                // Avoid seeking a third time when we were already at the end of the
                // stream. The branch is usually way cheaper than a seek operation.
                old != count ? seek(position: .start(old)) : .success(count)
            }
        }
    }

    public mutating func streamPosition() -> IOResult<UInt64> {
        seek(position: .current(0))
    }
}

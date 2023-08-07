#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

@frozen
public struct IOErrorKind: RawRepresentable, ExpressibleByIntegerLiteral {
    public let rawValue: UInt32

    @inlinable
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    @inlinable
    public init(integerLiteral value: UInt32) {
        rawValue = value
    }

    /// An entity was not found, often a file.
    public static let notFound: IOErrorKind = 0

    /// The operation lacked the necessary privileges to complete.
    public static let permissionDenied: IOErrorKind = 1

    /// The connection was refused by the remote server.
    public static let connectionRefused: IOErrorKind = 2

    /// The connection was reset by the remote server.
    public static let connectionReset: IOErrorKind = 3

    /// The remote host is not reachable.
    public static let hostUnreachable: IOErrorKind = 4

    /// The network containing the remote host is not reachable.
    public static let networkUnreachable: IOErrorKind = 5

    /// The connection was aborted (terminated) by the remote server.
    public static let connectionAborted: IOErrorKind = 6

    /// The network operation failed because it was not connected yet.
    public static let notConnected: IOErrorKind = 7

    /// A socket address could not be bound because the address is already in
    /// use elsewhere.
    public static let addrInUse: IOErrorKind = 8

    /// A nonexistent interface was requested or the requested address was not
    /// local.
    public static let addrNotAvailable: IOErrorKind = 9

    /// The system's networking is down.
    public static let networkDown: IOErrorKind = 10

    /// The operation failed because a pipe was closed.
    public static let brokenPipe: IOErrorKind = 11

    /// An entity already exists, often a file.
    public static let alreadyExists: IOErrorKind = 12

    /// The operation needs to block to complete, but the blocking operation was
    /// requested to not occur.
    public static let wouldBlock: IOErrorKind = 13

    /// A filesystem object is, unexpectedly, not a directory.
    ///
    /// For example, a filesystem path was specified where one of the intermediate directory
    /// components was, in fact, a plain file.
    public static let notADirectory: IOErrorKind = 14

    /// The filesystem object is, unexpectedly, a directory.
    ///
    /// A directory was specified when a non-directory was expected.
    public static let isADirectory: IOErrorKind = 15

    /// A non-empty directory was specified where an empty directory was expected.
    public static let directoryNotEmpty: IOErrorKind = 16

    /// The filesystem or storage medium is read-only, but a write operation was attempted.
    public static let readOnlyFilesystem: IOErrorKind = 17

    /// Loop in the filesystem or IO subsystem; often, too many levels of symbolic links.
    ///
    /// There was a loop (or excessively long chain) resolving a filesystem object
    /// or file IO object.
    ///
    /// On Unix this is usually the result of a symbolic link loop; or, of exceeding the
    /// system-specific limit on the depth of symlink traversal.
    public static let filesystemLoop: IOErrorKind = 18

    /// Stale network file handle.
    ///
    /// With some network filesystems, notably NFS, an open file (or directory) can be invalidated
    /// by problems with the network or server.
    public static let staleNetworkFileHandle: IOErrorKind = 19

    /// A parameter was incorrect.
    public static let invalidInput: IOErrorKind = 20

    /// Data not valid for the operation were encountered.
    ///
    /// Unlike [`InvalidInput`], this typically means that the operation
    /// parameters were valid, however the error was caused by malformed
    /// input data.
    ///
    /// For example, a function that reads a file into a string will error with
    /// `InvalidData` if the file's contents are not valid UTF-8.
    ///
    /// [`InvalidInput`]: ErrorKind::InvalidInput
    public static let invalidData: IOErrorKind = 21

    /// The I/O operation's timeout expired, causing it to be canceled.
    public static let timedOut: IOErrorKind = 22

    /// An error returned when an operation could not be completed because a
    /// call to [`write`] returned [`Ok(0)`].
    ///
    /// This typically means that an operation could only succeed if it wrote a
    /// particular number of bytes but only a smaller number of bytes could be
    /// written.
    ///
    /// [`write`]: crate::io::Write::write
    /// [`Ok(0)`]: Ok
    public static let writeZero: IOErrorKind = 23

    /// The underlying storage (typically, a filesystem) is full.
    ///
    /// This does not include out of quota errors.
    public static let storageFull: IOErrorKind = 24

    /// Seek on unseekable file.
    ///
    /// Seeking was attempted on an open file handle which is not suitable for seeking - for
    /// example, on Unix, a named pipe opened with `File::open`.
    public static let notSeekable: IOErrorKind = 25

    /// Filesystem quota was exceeded.
    public static let filesystemQuotaExceeded: IOErrorKind = 26

    /// File larger than allowed or supported.
    ///
    /// This might arise from a hard limit of the underlying filesystem or file access API, or from
    /// an administratively imposed resource limitation.  Simple disk full, and out of quota, have
    /// their own errors.
    public static let fileTooLarge: IOErrorKind = 27

    /// Resource is busy.
    public static let resourceBusy: IOErrorKind = 28

    /// Executable file is busy.
    ///
    /// An attempt was made to write to a file which is also in use as a running program.  (Not all
    /// operating systems detect this situation.)
    public static let executableFileBusy: IOErrorKind = 29

    /// Deadlock (avoided).
    ///
    /// A file locking operation would result in deadlock.  This situation is typically detected, if
    /// at all, on a best-effort basis.
    public static let deadlock: IOErrorKind = 30

    /// Cross-device or cross-filesystem (hard) link or rename.
    public static let crossesDevices: IOErrorKind = 31

    /// Too many (hard) links to the same filesystem object.
    ///
    /// The filesystem does not support making so many hardlinks to the same file.
    public static let tooManyLinks: IOErrorKind = 32

    /// A filename was invalid.
    ///
    /// This error can also cause if it exceeded the filename length limit.
    public static let invalidFilename: IOErrorKind = 33

    /// Program argument list too long.
    ///
    /// When trying to run an external program, a system or process limit on the size of the
    /// arguments would have been exceeded.
    public static let argumentListTooLong: IOErrorKind = 34

    /// This operation was interrupted.
    ///
    /// Interrupted operations can typically be retried.
    public static let interrupted: IOErrorKind = 35

    /// This operation is unsupported on this platform.
    ///
    /// This means that the operation can never succeed.
    public static let unsupported: IOErrorKind = 36

    // ErrorKinds which are primarily categorisations for OS error
    // codes should be added above.
    //
    /// An error returned when an operation could not be completed because an
    /// "end of file" was reached prematurely.
    ///
    /// This typically means that an operation could only succeed if it read a
    /// particular number of bytes but only a smaller number of bytes could be
    /// read.
    public static let unexpectedEof: IOErrorKind = 37

    /// An operation could not be completed, because it failed
    /// to allocate enough memory.
    public static let outOfMemory: IOErrorKind = 38

    // "Unusual" error kinds which do not correspond simply to (sets
    // of) OS error codes, should be added just above this comment.
    // ``other`` and ``uncategorized`` should remain at the end:
    //
    /// A custom error that does not fall under any other I/O error kind.
    ///
    /// This can be used to construct your own `Error`s that do not match any
    /// ``IOErrorKind``.
    ///
    /// This ``IOErrorKind`` is not used by the standard library.
    ///
    /// Errors from the standard library that do not fall under any of the I/O
    /// error kinds cannot be `match`ed on, and will only match a wildcard (`_`) pattern.
    /// New ``IOErrorKind``s might be added in the future for some of those.
    public static let other: IOErrorKind = 100

    /// Any I/O error from the standard library that's not part of this list.
    ///
    /// Errors that are ``uncategorized`` now may move to a different or a new
    /// ``IOErrorKind`` variant in the future. It is not recommended to match
    /// an error against ``uncategorized``; use a wildcard match (`_`) instead.
    public static let uncategorized: IOErrorKind = 255
}

extension IOErrorKind {
    static func decode(_ code: Int32) -> IOErrorKind {
        switch code {
        case E2BIG: return IOErrorKind.argumentListTooLong
        case EADDRINUSE: return IOErrorKind.addrInUse
        case EADDRNOTAVAIL: return IOErrorKind.addrNotAvailable
        case EBUSY: return IOErrorKind.resourceBusy
        case ECONNABORTED: return IOErrorKind.connectionAborted
        case ECONNREFUSED: return IOErrorKind.connectionRefused
        case ECONNRESET: return IOErrorKind.connectionReset
        case EDEADLK: return IOErrorKind.deadlock
        case EDQUOT: return IOErrorKind.filesystemQuotaExceeded
        case EEXIST: return IOErrorKind.alreadyExists
        case EFBIG: return IOErrorKind.fileTooLarge
        case EHOSTUNREACH: return IOErrorKind.hostUnreachable
        case EINTR: return IOErrorKind.interrupted
        case EINVAL: return IOErrorKind.invalidInput
        case EISDIR: return IOErrorKind.isADirectory
        case ELOOP: return IOErrorKind.filesystemLoop
        case ENOENT: return IOErrorKind.notFound
        case ENOMEM: return IOErrorKind.outOfMemory
        case ENOSPC: return IOErrorKind.storageFull
        case ENOSYS: return IOErrorKind.unsupported
        case EMLINK: return IOErrorKind.tooManyLinks
        case ENAMETOOLONG: return IOErrorKind.invalidFilename
        case ENETDOWN: return IOErrorKind.networkDown
        case ENETUNREACH: return IOErrorKind.networkUnreachable
        case ENOTCONN: return IOErrorKind.notConnected
        case ENOTDIR: return IOErrorKind.notADirectory
        case ENOTEMPTY: return IOErrorKind.directoryNotEmpty
        case EPIPE: return IOErrorKind.brokenPipe
        case EROFS: return IOErrorKind.readOnlyFilesystem
        case ESPIPE: return IOErrorKind.notSeekable
        case ESTALE: return IOErrorKind.staleNetworkFileHandle
        case ETIMEDOUT: return IOErrorKind.timedOut
        case ETXTBSY: return IOErrorKind.executableFileBusy
        case EXDEV: return IOErrorKind.crossesDevices
        default:
            if code == EAGAIN || code == EWOULDBLOCK {
                return IOErrorKind.wouldBlock
            }
            return IOErrorKind.uncategorized
        }
    }
}

@frozen
public struct IOError: Error {
    @usableFromInline
    let storage: Storage

    @inlinable
    init(_ storage: Storage) {
        self.storage = storage
    }

    public var kind: IOErrorKind {
        switch storage {
        case let .os(code):
            return IOErrorKind.decode(code)
        case let .simple(kind):
            return kind
        case let .message(kind, _):
            return kind
        case let .custom(kind, _):
            return kind
        }
    }

    @inlinable
    public static func message(kind: IOErrorKind, message: @autoclosure () -> String) -> IOError {
        IOError(.message(kind, message()))
    }

    @inlinable
    public static func fromRawOSError(_ code: Int32) -> IOError {
        IOError(.os(code))
    }

    @inlinable
    public static func lastOSError() -> IOError {
        fromRawOSError(errno)
    }

    @usableFromInline
    enum Storage {
        case os(Int32)
        case simple(IOErrorKind)
        case message(IOErrorKind, String)
        case custom(IOErrorKind, Error)
    }
}

public typealias IOResult<T> = Result<T, IOError>

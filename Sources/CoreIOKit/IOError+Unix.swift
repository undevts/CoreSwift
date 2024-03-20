#if !os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#endif

extension IOErrorKind {
    @usableFromInline
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
#endif // !os(Windows)
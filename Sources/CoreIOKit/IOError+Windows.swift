#if os(Windows)
import WinSDK

extension IOErrorKind {
    @usableFromInline
    static func decode(_ code: Int32) -> IOErrorKind {
        switch code {
            case ERROR_ACCESS_DENIED: return .permissionDenied
            case ERROR_ALREADY_EXISTS: return .alreadyExists
            case ERROR_FILE_EXISTS: return .alreadyExists
            case ERROR_BROKEN_PIPE: return .brokenPipe
            case WSAEACCES: return .permissionDenied
            default: return .uncategorized
        }
    }
}
#endif // os(Windows)

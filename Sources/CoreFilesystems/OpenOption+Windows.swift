#if os(Windows)

import WinSDK

#if SWIFT_PACKAGE
import CoreIOKit
#endif

// https://learn.microsoft.com/en-us/windows/win32/fileio/file-security-and-access-rights
let _FILE_GENERIC_WRITE: DWORD = 1179926

extension OpenOption {
    @usableFromInline
    struct Content {
        // generic
        @usableFromInline
        var read: Bool = false
        @usableFromInline
        var write: Bool = false
        @usableFromInline
        var append: Bool = false
        @usableFromInline
        var truncate: Bool = false
        @usableFromInline
        var create: Bool = false
        @usableFromInline
        var createNew: Bool = false
        // system-specific
        var customFlags: UInt32 = 0
        var accessMode: Optional<DWORD>
        var attributes: DWORD
        var shareMode: DWORD
        var securityQosFlags: DWORD
        // TODO: `LPSECURITY_ATTRIBUTES` is Pointer.
        var securityAttributes: Optional<LPSECURITY_ATTRIBUTES>

        @inline(__always)
        @usableFromInline
        init() {
            accessMode = nil
            attributes = 0
            shareMode = DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE)
            securityQosFlags = 0
            securityAttributes = nil
        }
    }
}

extension OpenOption.Content {
    @usableFromInline
    func resolveAccessMode() -> IOResult<DWORD> {
        switch (read, write, append, accessMode) {
        case let (_, _, _, .some(mode)):
            return .success(mode)
        case (true, false, false, .none):
            return .success(GENERIC_READ)
        case (false, true, false, .none):
            return .success(DWORD(GENERIC_WRITE))
        case (true, true, false, .none):
            return .success(GENERIC_READ | DWORD(GENERIC_WRITE))
        case (false, _, true, .none):
            // Swift says: macro 'FILE_GENERIC_WRITE' not imported: structure not supported
            return .success(_FILE_GENERIC_WRITE & ~DWORD(FILE_WRITE_DATA))
        case (true, _, true, .none):
            return .success(GENERIC_READ | (_FILE_GENERIC_WRITE & ~DWORD(FILE_WRITE_DATA)))
        case (false, false, false, .none):
            return .failure(IOError.fromRawOSError(ERROR_INVALID_PARAMETER))
        }
    }

    @inline(__always)
    @usableFromInline
    static func read() -> OpenOption {
        var content = OpenOption.Content()
        content.read = true
        return OpenOption(content)
    }

    @inline(__always)
    @usableFromInline
    static func write() -> OpenOption {
        var content = OpenOption.Content()
        content.write = true
        return OpenOption(content)
    }

    @inline(__always)
    @usableFromInline
    static func append() -> OpenOption {
        var content = OpenOption.Content()
        content.append = true
        return OpenOption(content)
    }
}

#endif // os(Windows)

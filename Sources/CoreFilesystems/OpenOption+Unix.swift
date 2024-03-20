#if !os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#endif

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
        @usableFromInline
        var customFlags: Int32
        @usableFromInline
        var mode: mode_t
        
        @inline(__always)
        @usableFromInline
        init() {
            customFlags = 0
            mode = 0o666
        }
    }
}

extension OpenOption.Content {
    @usableFromInline
    func flags() -> IOResult<CInt> {
        let accessMode: CInt
        switch resolveAccessMode() {
        case let .success(mode):
            accessMode = mode
        case let .failure(error):
            return .failure(error)
        }
        let creationMode: CInt
        switch resolveCreationMode() {
        case let .success(mode):
            creationMode = mode
        case let .failure(error):
            return .failure(error)
        }
        return .success(O_CLOEXEC | accessMode | creationMode | (customFlags & ~O_ACCMODE))
    }

    @usableFromInline
    func resolveAccessMode() -> IOResult<CInt> {
        switch (read, write, append) {
        case (true, false, false):
            return .success(O_RDONLY)
        case (false, true, false):
            return .success(O_WRONLY)
        case (true, true, false):
            return .success(O_RDWR)
        case (false, _, true):
            return .success(O_WRONLY | O_APPEND)
        case (true, _, true):
            return .success(O_RDWR | O_APPEND)
        case (false, false, false):
            return .failure(IOError.fromRawOSError(EINVAL))
        }
    }

    @usableFromInline
    func resolveCreationMode() -> IOResult<CInt> {
        switch (write, append) {
        case (true, false):
            break
        case (false, false):
            if truncate || create || createNew {
                return .failure(IOError.fromRawOSError(EINVAL))
            }
        case (_, true):
            if truncate && !createNew {
                return .failure(IOError.fromRawOSError(EINVAL))
            }
        }
        switch (create, truncate, createNew) {
        case (false, false, false):
            return .success(0)
        case (true, false, false):
            return .success(O_CREAT)
        case (false, true, false):
            return .success(O_TRUNC)
        case (true, true, false):
            return .success(O_CREAT | O_TRUNC)
        case (_, _, true):
            return .success(O_CREAT | O_EXCL)
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

#endif // !os(Windows)

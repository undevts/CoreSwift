#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

@frozen
public struct OpenOption: OptionSet {
    public let rawValue: Int32

    @inlinable
    @inline(__always)
    public init(rawValue: Int32) {
        self.rawValue = rawValue & ~O_ACCMODE
    }

    @inlinable
    @inline(__always)
    init(_ rawValue: Int32) {
        self.rawValue = rawValue
    }

    @inlinable
    @inline(__always)
    var flags: IOResult<Int32> {
        guard let accessMode = accessMode, let creationMode = creationMode else {
            return .failure(IOError.fromRawOSError(EINVAL))
        }
        return .success(O_CLOEXEC | accessMode | creationMode)
    }

    @inlinable
    @inline(__always)
    var accessMode: Int32? {
        // read, write, append
        switch (_contains(1), _contains(2), _contains(0b0000_0100)) {
        case (true, false, false):
            return O_RDONLY
        case (false, true, false):
            return O_WRONLY
        case (true, true, false):
            return O_RDWR
        case (false, _, true):
            return O_WRONLY | O_APPEND
        case (true, _, true):
            return O_RDWR | O_APPEND
        case (false, false, false):
            return nil
        }
    }

    @inlinable
    @inline(__always)
    var creationMode: Int32? {
        // write, append
        switch (_contains(2), _contains(0b0000_0100)) {
        case (true, false):
            break
        case (false, false):
            // truncate, create, create_new
            if _contains(0b0010_0000) || _contains(0b0000_1000) || _contains(0b0001_0000) {
                return nil
            }
        case (_, true):
            // truncate, create_new
            if _contains(0b0010_0000) && !_contains(0b0001_0000) {
                return nil
            }
        }
        // create, truncate, create_new
        switch (_contains(0b0000_1000), _contains(0b0010_0000), _contains(0b0001_0000)) {
        case (false, false, false):
            return 0
        case (true, false, false):
            return O_CREAT
        case (false, true, false):
            return O_TRUNC
        case (true, true, false):
            return O_CREAT | O_TRUNC
        case (_, _, true):
            return O_CREAT | O_EXCL
        }
    }

    @inlinable
    @inline(__always)
    func _contains(_ value: Int32) -> Bool {
        rawValue & value != 0
    }

    @inlinable
    @inline(__always)
    public static var read: OpenOption {
        OpenOption(1) // 1 << 0
    }

    @inlinable
    @inline(__always)
    public static var write: OpenOption {
        OpenOption(2) // 1 << 1
    }

    @inlinable
    @inline(__always)
    public static var readWrite: OpenOption {
        OpenOption(3) // 1 << 0 | 1 << 1
    }

    @inlinable
    @inline(__always)
    public static var append: OpenOption {
        OpenOption(0b0000_0100) // 1 << 2
    }

    @inlinable
    @inline(__always)
    public static var create: OpenOption {
        OpenOption(0b0000_1000) // 1 << 3
    }

    @inlinable
    @inline(__always)
    public static var createNew: OpenOption {
        OpenOption(0b0001_0000) // 1 << 4
    }

    @inlinable
    @inline(__always)
    public static var truncate: OpenOption {
        OpenOption(0b0010_0000) // 1 << 5
    }

    @inlinable
    @inline(__always)
    static var _read: Int32 {
        O_RDONLY
    }

    @inlinable
    @inline(__always)
    static var _create: Int32 {
        O_WRONLY | O_CREAT | O_TRUNC
    }

    @inlinable
    @inline(__always)
    static var _createNew: Int32 {
        O_RDWR | O_CREAT | O_EXCL
    }
}

extension OpenOption {
    @inlinable
    public func open(path: Path) -> IOResult<File> {
        File.open(path, option: self)
    }
}
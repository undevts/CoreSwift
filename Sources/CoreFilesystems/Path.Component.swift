#if SWIFT_PACKAGE
import CoreSwift
import CoreSystem
#endif

extension Path {
    @frozen
    public enum Prefix {
        /// Verbatim prefix, e.g., `\\?\cat_pics`.
        ///
        /// Verbatim prefixes consist of `\\?\` immediately followed by the given
        /// component.
        case verbatim(OsString)
        /// Verbatim prefix using Windows' _**U**niform **N**aming **C**onvention_,
        /// e.g., `\\?\UNC\server\share`.
        ///
        /// Verbatim UNC prefixes consist of `\\?\UNC\` immediately followed by the
        /// server's hostname and a share name.
        case verbatimUNC(OsString, OsString)
        /// Verbatim disk prefix, e.g., `\\?\C:`.
        ///
        /// Verbatim disk prefixes consist of `\\?\` immediately followed by the
        /// drive letter and `:`.
        case verbatimDisk(UInt8)
        /// Device namespace prefix, e.g., `\\.\COM42`.
        ///
        /// Device namespace prefixes consist of `\\.\` (possibly using `/`
        /// instead of `\`), immediately followed by the device name.
        case deviceNS(OsString)
        /// Prefix using Windows' _**U**niform **N**aming **C**onvention_, e.g.
        /// `\\server\share`.
        ///
        /// UNC prefixes consist of the server's hostname and a share name.
        case unc(OsString)
        /// Prefix `C:` for the given disk drive.
        case disk(UInt8)
    }

    @frozen
    public enum ComponentKind {
        /// A Windows path prefix, e.g., `C:` or `\\server\share`.
        ///
        /// There is a large variety of prefix types, see ``Path.Prefix``'s documentation
        /// for more.
        ///
        /// Does not occur on Unix.
        case prefix
        /// The root directory component, appears after any prefix and before anything else.
        ///
        /// It represents a separator that designates that a path starts from root.
        case root
        /// The special directory `.`, representing the current directory.
        case current
        /// The special directory `..`, representing the parent directory.
        case parent
        /// A normal component, e.g., `a` and `b` in `a/b`.
        ///
        /// This variant is the most common one, it represents references to files
        /// or directories.
        case regular
    }

    @frozen
    public struct Component: CustomStringConvertible, Equatable {
        @usableFromInline
        let storage: Storage

        @inlinable
        init(_ storage: Storage) {
            self.storage = storage
        }

        public var kind: ComponentKind {
            switch storage {
            case .prefix:
                return .prefix
            case .root:
                return .root
            case .current:
                return .current
            case .parent:
                return .parent
            case .regular:
                return .regular
            }
        }

        public var string: String {
            switch storage {
            case .prefix:
                return ""
            case .root:
                return "/"
            case .current:
                return "."
            case .parent:
                return ".."
            case let .regular(bytes):
                return bytes.string
            }
        }

        @inlinable
        public var description: String {
            string
        }

        @inlinable
        func append(into bytes: inout Bytes) {
            switch storage {
            case .prefix:
                break
            case .root:
                bytes.append(ASCII.solidus.rawValue)
            case .current:
                bytes.append(ASCII.fullStop.rawValue)
            case .parent:
                bytes.append(ASCII.fullStop.rawValue, ASCII.fullStop.rawValue)
            case let .regular(string):
                bytes.append(string.bytes)
            }
        }

        public func toPath() -> Path {
            switch storage {
            case .prefix:
                return Path()
            case .root, .current, .parent:
                var buffer = Bytes(capacity: 2)
                append(into: &buffer)
                return Path(buffer: buffer)
            case let .regular(string):
                return Path(buffer: string.bytes)
            }
        }

        public static func ==(lhs: Component, rhs: Component) -> Bool {
            switch (lhs.storage, rhs.storage) {
            case (.root, .root), (.current, .current), (.parent, .parent):
                return true
            case (.prefix, .prefix):
                return false
            case let (.regular(a), .regular(b)):
                return a == b
            default:
                return false
            }
        }

        @usableFromInline
        enum Storage {
            case prefix
            case root
            case current
            case parent
            case regular(OsString)
        }
    }
}

extension Path.Prefix {
    @inlinable
    var isDrive: Bool {
        false
    }

    @inlinable
    var hasImplicitRoot: Bool {
        !isDrive
    }

    var count: Int {
        0
    }
}

extension Path.Component {
    /// `Path("/")`
    @inlinable
    static func root() -> Path.Component {
        Path.Component(.root)
    }

    /// `Path(".")`
    @inlinable
    static func current() -> Path.Component {
        Path.Component(.current)
    }

    /// `Path("..")`
    @inlinable
    static func parent() -> Path.Component {
        Path.Component(.parent)
    }
}

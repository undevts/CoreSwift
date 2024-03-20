#if SWIFT_PACKAGE
import CoreIOKit
#endif

/// Options and flags which can be used to configure how a file is opened.
///
/// This builder exposes the ability to configure how a ``File`` is opened and
/// what operations are permitted on the open file. The [`File::open`] and
/// [`File::create`] methods are aliases for commonly used options using this
/// builder.
///
/// Generally speaking, when using `OpenOptions`, you'll first call
/// [`OpenOptions::new`], then chain calls to methods to set each option, then
/// call [`OpenOptions::open`], passing the path of the file you're trying to
/// open. This will give you a [`io::Result`] with a ``File`` inside that you
/// can further operate on.
@frozen
public struct OpenOption {
    @usableFromInline
    private(set) var content: Content

    @inlinable
    public init() {
        self.init(Content())
    }

    @_transparent
    @usableFromInline
    init(_ content: Content) {
        self.content = content
    }
}

extension OpenOption {
    @inlinable
    public var read: Bool {
        get { content.read }
        set { content.read = newValue }
    }

    @inlinable
    public var write: Bool {
        get { content.write }
        set { content.write = newValue }
    }

    @inlinable
    public var append: Bool {
        get { content.append }
        set { content.append = newValue }
    }

    @inlinable
    public var truncate: Bool {
        get { content.truncate }
        set { content.truncate = newValue }
    }

    @inlinable
    public var create: Bool {
        get { content.create }
        set { content.create = newValue }
    }

    @inlinable
    public var createNew: Bool {
        get { content.createNew }
        set { content.createNew = newValue }
    }

    @inlinable
    public static func read() -> OpenOption {
        Content.read()
    }

    @inlinable
    public static func write() -> OpenOption {
        Content.write()
    }

    @inlinable
    public static func append() -> OpenOption {
        Content.append()
    }
}

extension OpenOption {
#if os(Windows)
    public typealias AccessMode = UInt32 // DWORD
#else
    public typealias AccessMode = Int32 // c_int
#endif

    @inlinable
    public func accessMode() -> IOResult<AccessMode> {
        content.resolveAccessMode()
    }
}

extension OpenOption {
    @inlinable
    public func open(path: Path) -> IOResult<File> {
        FileDescriptor.open(path, option: content)
    }
}

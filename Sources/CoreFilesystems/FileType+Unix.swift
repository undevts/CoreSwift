#if !os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#endif

@frozen
public struct FileType: Hashable {
    @usableFromInline
    let raw: mode_t

    @inlinable
    init(raw: mode_t) {
        self.raw = raw
    }

    @inlinable
    @inline(__always)
    var masked: mode_t {
        raw & S_IFMT
    }

    /// Tests whether this file type represents a directory. The result is mutually
    /// exclusive to the results of ``isFile`` and ``isSymlink``; only zero or one
    /// of these tests may pass.
    @inlinable
    @inline(__always)
    public var isDirectory: Bool {
        isMode(S_IFDIR)
    }


    /// Tests whether this file type represents a regular file. The result is mutually
    /// exclusive to the results of ``isDirectory`` and ``isSymlink``; only zero or one
    /// of these tests may pass.
    ///
    /// When the goal is simply to read from (or write to) the source, the most reliable
    /// way to test the source can be read (or written to) is to open it. Only using
    /// ``isFile`` can break workflows like `diff <( prog_a )` on a Unix-like system for
    /// example. See [`File::open`] or [`OpenOptions::open`] for more information.
    @inlinable
    @inline(__always)
    public var isFile: Bool {
        isMode(S_IFREG)
    }

    /// Tests whether this file type represents a symbolic link. The result is mutually
    /// exclusive to the results of ``isDirectory`` and ``isFile``; only zero or one of
    /// these tests may pass.
    ///
    /// The underlying ``Metadata`` struct needs to be retrieved with the
    /// ``Filesystem/symlinkMetadata(path:)`` function and not the ``FileMetadata`` function.
    /// The ``FileMetadata`` function follows symbolic links, so ``isSymlink`` would
    /// always return `false` for the target file.
    @inlinable
    @inline(__always)
    public var isSymlink: Bool {
        isMode(S_IFLNK)
    }

    @inlinable
    @inline(__always)
    func isMode(_ mode: mode_t) -> Bool {
        masked == mode
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(masked)
    }

    @inlinable
    public static func ==(lhs: FileType, rhs: FileType) -> Bool {
        lhs.masked == rhs.masked
    }
}
#endif // !os(Windows)

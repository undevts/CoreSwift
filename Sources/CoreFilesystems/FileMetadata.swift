#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif os(Windows)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#endif

/// Metadata information about a file.
///
/// This structure is returned from the ``Filesystem/metadata(path:)`` or
/// ``Filesystem/symlinkMetadata(path:)`` function or method and represents known
/// metadata about a file such as its permissions, size, modification
/// times, etc.
@frozen
public struct FileMetadata {
#if os(Windows)
    @usableFromInline
    typealias Content = stat
#else
    @usableFromInline
    typealias Content = stat
#endif

    @usableFromInline
    let content: Content

    @inlinable
    init(content: Content) {
        self.content = content
    }

    /// Returns the size of the file, in bytes, this metadata is for.
    @inlinable
    public var size: UInt64 {
#if os(Windows)
        fatalError()
#else
        UInt64(content.st_size)
#endif
    }

    /// Returns the file type for this metadata.
    @inlinable
    public var fileType: FileType {
#if os(Windows)
        fatalError()
#else
        FileType(raw: content.st_mode)
#endif
    }

    /// Returns `true` if this metadata is for a directory. The
    /// result is mutually exclusive to the result of
    /// ``FileMetadata/isFile``, and will be false for symlink metadata
    /// obtained from ``Filesystem/symlinkMetadata(path:)``.
    @inlinable
    public var isDirectory: Bool {
#if os(Windows)
        fatalError()
#else
        fileType.isDirectory
#endif
    }

    /// Returns `true` if this metadata is for a regular file. The
    /// result is mutually exclusive to the result of
    /// ``FileMetadata/isDirectory``, and will be false for symlink metadata
    /// obtained from ``Filesystem/symlinkMetadata(path:)``.
    ///
    /// When the goal is simply to read from (or write to) the source, the most
    /// reliable way to test the source can be read (or written to) is to open
    /// it. Only using `is_file` can break workflows like `diff <( prog_a )` on
    /// a Unix-like system for example. See [`File::open`] or
    /// [`OpenOptions::open`] for more information.
    @inlinable
    public var isFile: Bool {
#if os(Windows)
        fatalError()
#else
        fileType.isFile
#endif
    }

    /// Returns `true` if this metadata is for a symbolic link.
    @inlinable
    public var isSymlink: Bool {
#if os(Windows)
        fatalError()
#else
        fileType.isSymlink
#endif
    }

    /// Returns the permissions of the file this metadata is for.
    @inlinable
    public var permissions: FilePermissions {
#if os(Windows)
        fatalError()
#else
        FilePermissions(content: content.st_mode)
#endif
    }
}

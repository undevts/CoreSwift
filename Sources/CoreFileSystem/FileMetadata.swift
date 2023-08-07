#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

@frozen
public struct FilePermissions: Hashable {
    @usableFromInline
    let raw: mode_t

    @inlinable
    init(raw: mode_t) {
        self.raw = raw
    }
}

/// Metadata information about a file.
///
/// This structure is returned from the ``Filesystem/metadata(path:)`` or
/// ``Filesystem/symlinkMetadata(path:)`` function or method and represents known
/// metadata about a file such as its permissions, size, modification
/// times, etc.
@frozen
public struct FileMetadata {
    @usableFromInline
    let raw: stat

    @inlinable
    init(raw: stat) {
        self.raw = raw
    }

    /// Returns the size of the file, in bytes, this metadata is for.
    @inlinable
    public var size: UInt64 {
        UInt64(raw.st_size)
    }

    /// Returns the file type for this metadata.
    @inlinable
    public var fileType: FileType {
        FileType(raw: raw.st_mode)
    }

    /// Returns `true` if this metadata is for a directory. The
    /// result is mutually exclusive to the result of
    /// ``FileMetadata/isFile``, and will be false for symlink metadata
    /// obtained from ``Filesystem/symlinkMetadata(path:)``.
    @inlinable
    public var isDirectory: Bool {
        fileType.isDirectory
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
        fileType.isFile
    }

    /// Returns `true` if this metadata is for a symbolic link.
    @inlinable
    public var isSymlink: Bool {
        fileType.isSymlink
    }
}

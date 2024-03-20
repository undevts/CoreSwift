#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif os(Windows)
import ucrt
#elseif canImport(Glibc)
import Glibc
#endif

#if !os(Windows)
/// Iterator over the entries in a directory.
///
/// This iterator is returned from the ``Filesystem/readDirectory(path:)``
/// function of this module and will yield instances of `IOResult<DirectoryEntry>`.
/// Through a ``DirectoryEntry`` information like the entry's path and possibly
/// other metadata can be learned.
///
/// The order in which this iterator returns entries is platform and filesystem
/// dependent.
///
/// # Errors
///
/// This ``IOResult`` will be an `.failure` if there's some sort of intermittent
/// IO error during iteration.
public final class ReadDirectory: Sequence {
    public typealias Element = IOResult<DirectoryEntry>

    let root: Path
    let pointer: UnsafeMutablePointer<DIR>

    init(root: Path, pointer: UnsafeMutablePointer<DIR>) {
        self.root = root
        self.pointer = pointer
    }

    deinit {
        let code = closedir(pointer)
        assert(code == 0 || IOError.lastOSError().kind == IOErrorKind.interrupted)
    }

    public func makeIterator() -> Iterator {
        Iterator(self)
    }

    @frozen
    public struct Iterator: IteratorProtocol {
        let directory: ReadDirectory

        init(_ directory: ReadDirectory) {
            self.directory = directory
        }

        var pointer: UnsafeMutablePointer<DIR> {
            directory.pointer
        }

        public func next() -> Element? {
            // `man readdir_r` says "The readdir_r() interface is deprecated".
            // https://lwn.net/Articles/696474/
            // https://github.com/rust-lang/rust/issues/40021

            // As of POSIX.1-2017, readdir() is not required to be thread safe; only
            // readdir_r() is. However, readdir_r() cannot correctly handle platforms
            // with unlimited or variable NAME_MAX.  Many modern platforms guarantee
            // thread safety for readdir() as long an individual DIR* is not accessed
            // concurrently.
            while true {
                errno = 0
                guard let entry = readdir(pointer) else {
                    // null can mean either the end is reached or an error occurred.
                    // So we had to clear errno beforehand to check for an error now.
                    switch errno {
                    case 0:
                        return nil
                    case let some:
                        return .failure(IOError.fromRawOSError(some))
                    }
                }

                // d_name is guaranteed to be null-terminated.
                let name = name(of: entry)
                if name == "." || name == ".." {
                    continue
                }

                return .success(DirectoryEntry(directory, filename: name,
                    d_ino: entry.pointee.d_ino, d_type: entry.pointee.d_type))
            }
        }
    }
}

/// Entries returned by the ``ReadDirectory`` iterator.
///
/// An instance of `DirectoryEntry` represents an entry inside of a directory
/// on the filesystem.
///
/// # Platform-specific behavior
///
/// On Unix, the `DirectoryEntry` struct contains an internal reference to the open
/// directory. Holding `DirectoryEntry` objects will consume a file handle even
/// after the `ReadDirectory` iterator is dropped.
@frozen
public struct DirectoryEntry {
    public let filename: String
    let directory: ReadDirectory
    let d_ino: UInt64
    let d_type: UInt8

    init(_ directory: ReadDirectory, filename: String, d_ino: UInt64, d_type: UInt8) {
        self.directory = directory
        self.filename = filename
        self.d_ino = d_ino
        self.d_type = d_type
    }

    public var path: Path {
        directory.root.appending(filename)
    }

    public func metadata() -> IOResult<FileMetadata> {
        IO.call { () -> Int32 in
            dirfd(directory.pointer)
        }.flatMap { fd -> IOResult<FileMetadata> in
            var stat = stat()
            return IO.call { () -> Int32 in
                // TODO: filename String or Bytes?
                fstatat(fd, filename, &stat, AT_SYMLINK_NOFOLLOW)
            }.map { _ in
                FileMetadata(content: stat)
            }
        }
    }

    public func fileType() -> IOResult<FileType> {
        switch Int32(d_type) {
        case DT_CHR: return .success(FileType(raw: S_IFCHR))
        case DT_FIFO: return .success(FileType(raw: S_IFIFO))
        case DT_LNK: return .success(FileType(raw: S_IFLNK))
        case DT_REG: return .success(FileType(raw: S_IFREG))
        case DT_SOCK: return .success(FileType(raw: S_IFSOCK))
        case DT_DIR: return .success(FileType(raw: S_IFDIR))
        case DT_BLK: return .success(FileType(raw: S_IFBLK))
        default:
            return metadata().map(\.fileType)
        }
    }
}

// d_name is (CChar, CChar, CChar, ...)
@inlinable
@inline(__always)
func name(of entry: UnsafePointer<dirent>) -> String {
    var pointer = UnsafeRawPointer(entry)
        .assumingMemoryBound(to: UInt8.self)
    pointer += (MemoryLayout<dirent>.offset(of: \.d_name) ?? 0)
    return String(cString: pointer)
}
#endif // os(Windows)

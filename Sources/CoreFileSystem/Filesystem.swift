#if canImport(Glibc)
import Glibc
#else
import Darwin.C
#endif

#if SWIFT_PACKAGE
import CoreSwift
#endif

// Rust: https://doc.rust-lang.org/std/fs/index.html
// Node.js https://nodejs.org/api/IO.html
// C++ https://en.cppreference.com/w/cpp/filesystem

public struct Filesystem {
    @inlinable
    @inline(__always)
    static func _stat(path: Path) -> IOResult<FileMetadata> {
        var temp: stat = stat()
        return IO.call {
            path.withCString { pointer -> Int32 in
                stat(pointer, &temp)
            }
        }.map { _ in
            FileMetadata(raw: temp)
        }
    }

    @inlinable
    @inline(__always)
    static func _lstat(path: Path) -> IOResult<FileMetadata> {
        var temp: stat = stat()
        return IO.call {
            path.withCString { pointer -> Int32 in
                lstat(pointer, &temp)
            }
        }.map { _ in
            FileMetadata(raw: temp)
        }
    }

    @inlinable
    @inline(__always)
    static func _fstat(_ descriptor: Int32) -> IOResult<FileMetadata> {
        var temp: stat = stat()
        return IO.call {
            fstat(descriptor, &temp)
        }.map { _ in
            FileMetadata(raw: temp)
        }
    }

    public static func metadata(path: Path) -> IOResult<FileMetadata> {
        _stat(path: path)
    }

    public static func symlinkMetadata(path: Path) -> IOResult<FileMetadata> {
        _lstat(path: path)
    }

    public static func exists(path: Path) -> Bool {
        metadata(path: path).isSuccess
    }

    public static func tryExists(path: Path) -> IOResult<Bool> {
        switch metadata(path: path) {
        case .success:
            return .success(true)
        case let .failure(error):
            return error.kind == IOErrorKind.notFound ? .success(false) : .failure(error)
        }
    }

    /// Read the entire contents of a file into a bytes vector.
    ///
    /// This is a convenience function for using ``File.open`` and ``File.readToEnd``
    /// with fewer imports and without an intermediate variable.
    ///
    /// # Errors
    ///
    /// This function will return an error if `path` does not already exist.
    /// Other errors may also be returned according to [`OpenOptions::open`].
    ///
    /// It will also return an error if it encounters while reading an error
    /// of a kind other than ``IOErrorKind.interrupted``.
    public static func read(path: Path) -> IOResult<Bytes> {
        let file = File.open(path)
        return file.flatMap { f -> IOResult<Bytes> in
            var bytes = Bytes()
            return f.readToEnd(buffer: &bytes)
                .map { _ in bytes }
        }
    }

    /// Returns an iterator over the entries within a directory.
    ///
    /// The iterator will yield instances of `IOResult<ReadDirectory>`.
    /// New errors may be encountered after an iterator is initially constructed.
    /// Entries for the current and parent directories (typically `.` and `..`) are
    /// skipped.
    ///
    /// The order in which this iterator returns entries is platform and filesystem
    /// dependent.
    ///
    /// # Errors
    ///
    /// This function will return an error in the following situations, but is not
    /// limited to just these cases:
    ///
    /// * The provided `path` doesn't exist.
    /// * The process lacks permissions to view the contents.
    /// * The `path` points at a non-directory file.
    public static func readDirectory(path: Path) -> IOResult<ReadDirectory> {
        let pointer = path.withCString { pointer -> UnsafeMutablePointer<DIR>? in
            opendir(pointer)
        }
        guard let pointer = pointer else {
            return .failure(IOError.lastOSError())
        }
        return .success(ReadDirectory(root: path, pointer: pointer))
    }
}

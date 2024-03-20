#if !os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
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
            FileMetadata(content: temp)
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
            FileMetadata(content: temp)
        }
    }

    @inlinable
    @inline(__always)
    static func _fstat(_ descriptor: Int32) -> IOResult<FileMetadata> {
        var temp: stat = stat()
        return IO.call {
            fstat(descriptor, &temp)
        }.map { _ in
            FileMetadata(content: temp)
        }
    }

    /// Queries metadata about the underlying file.
    public static func metadata(path: Path) -> IOResult<FileMetadata> {
        _stat(path: path)
    }

    /// Query the metadata about a file without following symlinks.
    ///
    /// # Platform-specific behavior
    ///
    /// This function currently corresponds to the `lstat` function on Unix
    /// and the `GetFileInformationByHandle` function on Windows.
    /// Note that, this [may change in the future][changes].
    ///
    /// [changes]: io#platform-specific-behavior
    ///
    /// # Errors
    ///
    /// This function will return an error in the following situations, but is not
    /// limited to just these cases:
    ///
    /// * The user lacks permissions to perform `metadata` call on `path`.
    /// * `path` does not exist.
    public static func symlinkMetadata(path: Path) -> IOResult<FileMetadata> {
        _lstat(path: path)
    }

    public static func exists(path: Path) -> Bool {
        metadata(path: path).isSuccess
    }

    /// Returns `Ok(true)` if the path points at an existing entity.
    ///
    /// This function will traverse symbolic links to query information about the
    /// destination file. In case of broken symbolic links this will return `Ok(false)`.
    ///
    /// As opposed to the [`Path::exists`] method, this will only return `Ok(true)` or `Ok(false)`
    /// if the path was _verified_ to exist or not exist. If its existence can neither be confirmed
    /// nor denied, an `Err(_)` will be propagated instead. This can be the case if e.g. listing
    /// permission is denied on one of the parent directories.
    ///
    /// Note that while this avoids some pitfalls of the `exists()` method, it still can not
    /// prevent time-of-check to time-of-use (TOCTOU) bugs. You should only use it in scenarios
    /// where those bugs are not an issue.
    ///
    /// # Examples
    ///
    /// ```no_run
    /// #![feature(fs_try_exists)]
    /// use std::fs;
    ///
    /// assert!(!fs::try_exists("does_not_exist.txt").expect("Can't check existence of file does_not_exist.txt"));
    /// assert!(fs::try_exists("/root/secret_file.txt").is_err());
    /// ```
    ///
    /// [`Path::exists`]: crate::path::Path::exists
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
    /// This is a convenience function for using ``File.open`` and ``File.readAll``
    /// with fewer imports and without an intermediate variable.
    ///
    /// # Errors
    ///
    /// This function will return an error if `path` does not already exist.
    /// Other errors may also be returned according to ``OpenOption.open``.
    ///
    /// It will also return an error if it encounters while reading an error
    /// of a kind other than ``IOErrorKind.interrupted``.
    public static func read(path: Path) -> IOResult<Bytes> {
        fatalError()
//        let file = File.open(path)
//        return file.flatMap { f -> IOResult<Bytes> in
//            var bytes = Bytes()
//            return f.readAll(buffer: &bytes)
//                .map { _ in bytes }
//        }
    }

    /// Returns an iterator over the entries within a directory.
    ///
    /// The iterator will yield instances of ``IOResult<ReadDirectory>``.
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
#endif // !os(Windows)

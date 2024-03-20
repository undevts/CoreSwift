#if SWIFT_PACKAGE
import CoreIOKit
#endif

// Rust File https://doc.rust-lang.org/std/fs/struct.File.html
// Java File https://docs.oracle.com/javase/8/docs/api/java/io/File.html
// Apple FileDescriptor https://developer.apple.com/documentation/system/filedescriptor/

/// An object providing access to an open file on the filesystem.
///
/// An instance of a `File` can be read and/or written depending on what options
/// it was opened with. Files also implement [`Seek`] to alter the logical cursor
/// that the file contains internally.
///
/// Files are automatically closed when they go out of scope.  Errors detected
/// on closing are ignored by the implementation of `Drop`.  Use the method
/// [`sync_all`] if these errors must be manually handled.
///
/// # Examples
///
/// Creates a new file and write bytes to it (you can also use [`write()`]):
///
/// ```no_run
/// use std::fs::File;
/// use std::io::prelude::*;
///
/// fn main() -> std::io::Result<()> {
///     let mut file = File::create("foo.txt")?;
///     file.write_all(b"Hello, world!")?;
///     Ok(())
/// }
/// ```
///
/// Read the contents of a file into a [`String`] (you can also use [`read`]):
///
/// ```no_run
/// use std::fs::File;
/// use std::io::prelude::*;
///
/// fn main() -> std::io::Result<()> {
///     let mut file = File::open("foo.txt")?;
///     let mut contents = String::new();
///     file.read_to_string(&mut contents)?;
///     assert_eq!(contents, "Hello, world!");
///     Ok(())
/// }
/// ```
///
/// It can be more efficient to read the contents of a file with a buffered
/// [`Read`]er. This can be accomplished with [`BufReader<R>`]:
///
/// ```no_run
/// use std::fs::File;
/// use std::io::BufReader;
/// use std::io::prelude::*;
///
/// fn main() -> std::io::Result<()> {
///     let file = File::open("foo.txt")?;
///     let mut buf_reader = BufReader::new(file);
///     let mut contents = String::new();
///     buf_reader.read_to_string(&mut contents)?;
///     assert_eq!(contents, "Hello, world!");
///     Ok(())
/// }
/// ```
///
/// Note that, although read and write methods require a `&mut File`, because
/// of the interfaces for [`Read`] and [`Write`], the holder of a `&File` can
/// still modify the file, either through methods that take `&File` or by
/// retrieving the underlying OS object and modifying the file that way.
/// Additionally, many operating systems allow concurrent modification of files
/// by different processes. Avoid assuming that holding a `&File` means that the
/// file will not change.
///
/// # Platform-specific behavior
///
/// On Windows, the implementation of [`Read`] and [`Write`] traits for `File`
/// perform synchronous I/O operations. Therefore the underlying file must not
/// have been opened for asynchronous I/O (e.g. by using `FILE_FLAG_OVERLAPPED`).
///
/// [`BufReader<R>`]: io::BufReader
/// [`sync_all`]: File::sync_all
@frozen
public struct File {
#if os(Windows)
    @usableFromInline
    typealias Content = FileDescriptor
#else
    @usableFromInline
    typealias Content = FileDescriptor
#endif

    @usableFromInline
    let content: Content

    @usableFromInline
    init(_ content: Content) {
        self.content = content
    }
}

extension File {
    @inlinable
    public static func open(_ path: Path) -> IOResult<File> {
#if os(Windows)
        fatalError()
#else
        FileDescriptor.open(path)
#endif
    }

    @inlinable
    public static func create(_ path: Path) -> IOResult<File> {
#if os(Windows)
        fatalError()
#else
        FileDescriptor.create(path)
#endif
    }

    @inlinable
    public static func createNew(_ path: Path) -> IOResult<File> {
#if os(Windows)
        fatalError()
#else
        FileDescriptor.createNew(path)
#endif
    }
}

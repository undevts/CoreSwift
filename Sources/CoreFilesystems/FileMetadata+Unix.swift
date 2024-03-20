#if !os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#endif

extension FileMetadata {
    @inlinable
    @inline(__always)
    public func dev() -> UInt64 {
        UInt64(content.st_dev)
    }

    @inlinable
    @inline(__always)
    public func ino() -> UInt64 {
        UInt64(content.st_ino)
    }

    @inlinable
    @inline(__always)
    public func mode() -> UInt32 {
        UInt32(content.st_mode)
    }

    @inlinable
    @inline(__always)
    public func nlink() -> UInt64 {
        UInt64(content.st_nlink)
    }

    @inlinable
    @inline(__always)
    public func uid() -> UInt32 {
        UInt32(content.st_uid)
    }

    @inlinable
    @inline(__always)
    public func gid() -> UInt32 {
        UInt32(content.st_gid)
    }

    @inlinable
    @inline(__always)
    public func rdev() -> UInt64 {
        UInt64(content.st_rdev)
    }

    @inlinable
    @inline(__always)
    public func length() -> UInt64 {
        UInt64(content.st_size)
    }

    @inlinable
    @inline(__always)
    public func atime() -> Int64 {
        Int64(content.st_atimespec.tv_sec)
    }

    @inlinable
    @inline(__always)
    public func atimeNano() -> Int64 {
        Int64(content.st_atimespec.tv_nsec)
    }

    @inlinable
    @inline(__always)
    public func mtime() -> Int64 {
        Int64(content.st_mtimespec.tv_sec)
    }

    @inlinable
    @inline(__always)
    public func mtimeNano() -> Int64 {
        Int64(content.st_mtimespec.tv_nsec)
    }

    @inlinable
    @inline(__always)
    public func ctime() -> Int64 {
        Int64(content.st_ctimespec.tv_sec)
    }

    @inlinable
    @inline(__always)
    public func ctimeNano() -> Int64 {
        Int64(content.st_ctimespec.tv_nsec)
    }

    @inlinable
    @inline(__always)
    public func blksize() -> UInt64 {
        UInt64(content.st_blksize)
    }

    @inlinable
    @inline(__always)
    public func blocks() -> UInt64 {
        UInt64(content.st_blocks)
    }
}

#endif // !os(Windows)

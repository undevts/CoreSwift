public struct IO {
    @inlinable
    @inline(__always)
    public static func call<R>(
        _ method: () -> R
    ) -> IOResult<R> where R: SignedInteger & FixedWidthInteger {
        let code = method()
        return code == -1 ? .failure(.lastOSError()) : .success(code)
    }

    @inlinable
    @inline(__always)
    public static func call<T, R>(
        _ target: inout T,
        _ method: (inout T) -> R
    ) -> IOResult<R> where R: SignedInteger & FixedWidthInteger {
        let code = method(&target)
        return code == -1 ? .failure(.lastOSError()) : .success(code)
    }

    // The maximum read limit on most POSIX-like systems is `SSIZE_MAX`,
    // with the man page quoting that if the count of bytes to read is
    // greater than `SSIZE_MAX` the result is "unspecified".
    //
    // On macOS, however, apparently the 64-bit libc is either buggy or
    // intentionally showing odd behavior by rejecting any read with a size
    // larger than or equal to INT_MAX. To handle both of these the read
    // size is capped on both platforms.
    @_transparent
    public static var readLimit: Int {
        Int.max - 1
    }
}
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif os(Windows)
import ucrt
#elseif canImport(Glibc)
import Glibc
#endif

public final class FileDescriptor {
    public let raw: CInt
    @usableFromInline
    private(set) var holder = Holder()

    @inlinable
    public init(_ raw: CInt) {
        self.raw = raw
    }

    deinit {
        if isKnownUniquelyReferenced(&holder) {
            _ = close(raw)
        }
    }

    @usableFromInline
    class Holder {
        @usableFromInline
        init() {}
    }
}

#if os(Windows)
import WinSDK

#if SWIFT_PACKAGE
import CoreSwift
#endif

public struct OwnedHandle {
    @OwnedPointer
    public var handle: HANDLE

    public init(handle: HANDLE) {
        _handle = OwnedPointer(handle, dealloc: OwnedHandle.drop(_:))
    }

    @inlinable
    @inline(__always)
    static func drop(_ handle: HANDLE) {
        CloseHandle(handle)
    }
}
#endif // os(Windows)

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin.C
#elseif os(Windows)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#endif

@frozen
public struct FilePermissions: Hashable {
#if os(Windows)
    @usableFromInline
    typealias Content = DWORD
#else
    @usableFromInline
    typealias Content = mode_t
#endif

    @usableFromInline
    private(set) var content: Content

    @inlinable
    init(content: Content) {
        self.content = content
    }

    public var readonly: Bool {
        get { _readonly() }
        set { _setReadonly(newValue) }
    }
}

#if os(Windows)
extension FilePermissions {
    func _readonly() -> Bool {
        fatalError()
    }

    mutating func _setReadonly(_ readonly: Bool) {
        fatalError()
    }
}
#else
extension FilePermissions {
    @inlinable
    @inline(__always)
    func _readonly() -> Bool {
        // check if any class (owner, group, others) has write permission
        content & 0o222 == 0
    }

    @inlinable
    @inline(__always)
    mutating func _setReadonly(_ readonly: Bool) {
        if readonly {
            // remove write permission for all classes; equivalent to `chmod a-w <file>`
            content &= ~0o222
        } else {
            // add write permission for all classes; equivalent to `chmod a+w <file>`
            content |= 0o222
        }
    }
}
#endif

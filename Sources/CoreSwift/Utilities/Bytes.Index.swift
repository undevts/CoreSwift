#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

extension Bytes {
    @frozen
    public struct Index {
        @usableFromInline
        var data: Pointer

        @_transparent
        @usableFromInline
        init(_ data: Pointer) {
            self.data = data
        }
    }
}

extension Bytes.Index {
    @inlinable
    public static func -(lhs: Bytes.Index, rhs: Bytes.Index) -> Int {
        lhs.data - rhs.data
    }
}

extension Bytes.Index: Comparable {
    @inlinable
    public static func <(lhs: Bytes.Index, rhs: Bytes.Index) -> Bool {
        lhs.data < rhs.data
    }

    @inlinable
    public static func <=(lhs: Bytes.Index, rhs: Bytes.Index) -> Bool {
        lhs.data <= rhs.data
    }

    @inlinable
    public static func >(lhs: Bytes.Index, rhs: Bytes.Index) -> Bool {
        lhs.data > rhs.data
    }

    @inlinable
    public static func >=(lhs: Bytes.Index, rhs: Bytes.Index) -> Bool {
        lhs.data >= rhs.data
    }

    @inlinable
    public static func ==(lhs: Bytes.Index, rhs: Bytes.Index) -> Bool {
        lhs.data == rhs.data
    }
}

extension Bytes.Index: Strideable {
    public typealias Stride = Int

    @inlinable
    @inline(__always)
    public func advanced(by n: Int) -> Bytes.Index {
        Bytes.Index(data + n)
    }

    @inlinable
    @inline(__always)
    public func distance(to other: Bytes.Index) -> Int {
        data - other.data
    }

    @inlinable
    public static func + (lhs: Bytes.Index, rhs: Int) -> Bytes.Index {
        Bytes.Index(lhs.data + rhs)
    }

    @inlinable
    public static func + (lhs: Bytes.Index, rhs: UInt) -> Bytes.Index {
        Bytes.Index(cci_bytes_plus(lhs.data, rhs))
    }

    @inlinable
    public static func - (lhs: Bytes.Index, rhs: Int) -> Bytes.Index {
        Bytes.Index(lhs.data - rhs)
    }

    @inlinable
    public static func - (lhs: Bytes.Index, rhs: UInt) -> Bytes.Index {
        Bytes.Index(cci_bytes_minus(lhs.data, rhs))
    }

    @inlinable
    public static func += (lhs: inout Bytes.Index, rhs: Int) {
        lhs.data += rhs
    }

    @inlinable
    public static func += (lhs: inout Bytes.Index, rhs: UInt) {
        lhs.data = cci_bytes_plus(lhs.data, rhs)
    }

    @inlinable
    public static func -= (lhs: inout Bytes.Index, rhs: Int) {
        lhs.data -= rhs
    }

    @inlinable
    public static func -= (lhs: inout Bytes.Index, rhs: UInt) {
        lhs.data = cci_bytes_minus(lhs.data, rhs)
    }
}

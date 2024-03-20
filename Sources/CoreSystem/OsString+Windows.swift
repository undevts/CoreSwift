#if os(Windows)

extension OsString {
    /// Creates an ``OsString`` from a potentially ill-formed UTF-16 slice of 16-bit code units.
    /// This is lossless, the resulting string will always return the original code units.
    @inlinable
    public static func fromWide<Iterator>(iterator: __owned Iterator, count: Int?) -> OsString
        where Iterator: IteratorProtocol, Iterator.Element == UInt16 {
        OsString(content: WTF8.fromWide(iterator: iterator, count: count))
    }
}

#endif // os(Windows)

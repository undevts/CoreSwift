extension Path {
    @frozen
    public struct Index {
        @usableFromInline
        let start: Bytes.Index
        @usableFromInline
        let content: Bytes.Index
        @usableFromInline
        let end: Bytes.Index
        @usableFromInline
        let state: ParseState

        @inlinable
        @inline(__always)
        init(_ index: Bytes.Index, _ state: ParseState) {
            start = index
            content = index
            end = index
            self.state = state
        }

        @inlinable
        @inline(__always)
        init(_ start: Bytes.Index, _ end: Bytes.Index, _ state: ParseState) {
            self.start = start
            content = start
            self.end = end
            self.state = state
        }

        @inlinable
        @inline(__always)
        init(_ start: Bytes.Index, _ content: Bytes.Index, _ end: Bytes.Index, _ state: ParseState) {
            self.start = start
            self.content = content
            self.end = end
            self.state = state
        }

        @inlinable
        @inline(__always)
        var range: ClosedRange<Bytes.Index> {
            start...end
        }
    }
}

extension Path.Index: Comparable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        if lhs.content == rhs.content {
            return true
        }
        if lhs.state == .done {
            return lhs.range.contains(rhs.content)
        }
        if rhs.state == .done {
            return rhs.range.contains(lhs.content)
        }
        return false
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.state == .done {
            return lhs.end < rhs.content
        }
        if rhs.state == .done {
            return rhs.end < lhs.content
        }
        return lhs.content < rhs.content
    }

//    public static func >(lhs: Self, rhs: Self) -> Bool {
//        lhs.content > rhs.content
//    }
//
//    public static func <=(lhs: Self, rhs: Self) -> Bool {
//        lhs.content <= rhs.content
//    }
//
//    public static func >=(lhs: Self, rhs: Self) -> Bool {
//        lhs.content >= rhs.content
//    }
}

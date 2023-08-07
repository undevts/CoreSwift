#if SWIFT_PACKAGE
import CoreSwift
#endif

extension Path {
    @usableFromInline
    enum ParseState: Int, Comparable {
        case prefix // c:
        case startDirectory // / or . or nothing
        case body // foo/bar/baz
        case done

        @inlinable
        @inline(__always)
        static func <(lhs: ParseState, rhs: ParseState) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        @inlinable
        @inline(__always)
        static func >(lhs: ParseState, rhs: ParseState) -> Bool {
            lhs.rawValue > rhs.rawValue
        }

        @inlinable
        @inline(__always)
        static func >=(lhs: ParseState, rhs: ParseState) -> Bool {
            lhs.rawValue >= rhs.rawValue
        }

        @inlinable
        @inline(__always)
        static func <=(lhs: ParseState, rhs: ParseState) -> Bool {
            lhs.rawValue <= rhs.rawValue
        }
    }
}

extension Path {
    @frozen
    public struct ComponentView: Sequence {
        public typealias Element = Component

        @usableFromInline
        let bytes: Bytes
        @usableFromInline
        let prefix: Path.Prefix?
        @usableFromInline
        let hasPhysicalRoot: Bool

        @inlinable
        init(bytes: Bytes, prefix: Path.Prefix?, hasPhysicalRoot: Bool) {
            self.bytes = bytes
            self.prefix = prefix
            self.hasPhysicalRoot = hasPhysicalRoot
        }

        @inlinable
        @inline(__always)
        var hasRoot: Bool {
            if hasPhysicalRoot {
                return true
            }
            return prefix?.hasImplicitRoot ?? false
        }

        var prefixCount: Int {
            0
        }

        var prefixVerbatim: Bool {
            false
        }

        @usableFromInline
        func prefixRemaining() -> Int {
            0
        }

        @inlinable
        @inline(__always)
        func makeComponents(inverse: Bool) -> Components {
            Components(self, front: .prefix, back: .body, inverse: inverse)
        }

        @inlinable
        public func makeIterator() -> Iterator {
            makeComponents(inverse: false)
                .toIterator()
        }

        @inlinable
        public func makeBackIterator() -> BackIterator {
            makeComponents(inverse: true)
                .toBackIterator()
        }
    }
}

extension Path.ComponentView {
    // TODO: Remove this
    public var path: Path {
        toPath()
    }

    public func toPath() -> Path {
        var view = makeComponents(inverse: false)
        if view.front == .body {
            view.trimLeft()
        }
        if view.back == .body {
            view.trimRight()
        }
        return Path(buffer: view.bytes)
    }
}

extension Path.ComponentView: Equatable {
    public static func ==(lhs: Path.ComponentView, rhs: Path.ComponentView) -> Bool {
        // Fast path for exact matches, e.g. for hashmap lookups.
        // Don't explicitly compare the prefix or has_physical_root fields since they'll
        // either be covered by the `path` buffer or are only relevant for `prefix_verbatim()`.
        if lhs.bytes.count == rhs.bytes.count &&
            lhs.prefixVerbatim == rhs.prefixVerbatim {
            if lhs.bytes == rhs.bytes {
                return true
            }
        }
        // compare back to front since absolute paths often share long prefixes
        var i = lhs.makeBackIterator()
        var j = rhs.makeBackIterator()
        while true {
            switch (i.next(), j.next()) {
            case (.none, .none):
                continue
            case let (.some(a), .some(b)):
                if a != b {
                    return false
                }
            default:
                return false
            }
        }
    }
}

extension Path.ComponentView: Collection {
    public typealias SubSequence = Path.ComponentView
    public typealias Index = Path.Index

    public var underestimatedCount: Int {
        count
    }

    public var count: Int {
        var i = 0
        var view = makeComponents(inverse: false)
        while view.next() != nil {
            i += 1
        }
        return i
    }

    public var startIndex: Index {
        // TODO: Ugly
        // Index(bytes.startIndex, .prefix)
        let view = makeComponents(inverse: false)
        return view.nextComponent()
    }

    public var endIndex: Index {
        Index(bytes.endIndex, .body)
        // TODO: Ugly
        // Index(bytes.endIndex, .body)
//        let view = makeComponents(inverse: true)
//        let last = view.previousComponent()
//        return Index(last.end, bytes.endIndex, .body)
    }

    public func index(after i: Index) -> Index {
        var view = Path.Components(self, current: i.end, front: i.state, back: .body)
        return view.nextIndex()
    }

    public func distance(from start: Index, to end: Index) -> Int {
        var i = 0
        var view = Path.Components(self, current: start.end, front: start.state, back: .body)
        var current = start
        while current < end {
            current = view.nextIndex()
            i += 1
        }
        return i
    }

    public subscript(position: Index) -> Path.Component {
        precondition(startIndex <= position && position < endIndex)
        var view = Path.Components(self, current: position.content, front: position.state, back: .body)
#if DEBUG
        let result = view.next()
        if result == nil {
            preconditionFailure(#function)
        }
        return result!
#else
        return view.next()!
#endif
    }

    public subscript(bounds: Range<Index>) -> Path.ComponentView {
        let range = bounds.lowerBound.content..<bounds.upperBound.content
        return Path(buffer: bytes[range]).components
    }
}

extension Path.ComponentView: BidirectionalCollection {
    public func index(before i: Index) -> Index {
        var view = Path.Components(self, current: i.start, front: .prefix, back: i.state)
        return view.previousIndex()
    }
}

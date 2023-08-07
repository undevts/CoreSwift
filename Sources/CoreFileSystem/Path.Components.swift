#if SWIFT_PACKAGE
import CoreSwift
#endif

extension Path {
    @usableFromInline
    struct Components {
        private(set) var bytes: Bytes
        let prefix: Path.Prefix?
        /// true if path *physically* has a root separator; for most Windows
        /// prefixes, it may have a "logical" root separator for the purposes of
        /// normalization, e.g., \\server\share == \\server\share\.
        let hasPhysicalRoot: Bool
        private(set) var front: Path.ParseState
        private(set) var back: Path.ParseState
        private(set) var index: Bytes.Index

        @inlinable
        @inline(__always)
        init(_ view: Path.ComponentView, front: Path.ParseState, back: Path.ParseState, inverse: Bool) {
            self.init(view, current: inverse ? view.bytes.endIndex : view.bytes.startIndex,
                front: front, back: back)
        }

        @usableFromInline
        init(_ view: Path.ComponentView, current index: Bytes.Index,
            front: Path.ParseState, back: Path.ParseState) {
            precondition(view.bytes.startIndex <= index && index <= view.bytes.endIndex)
            bytes = view.bytes
            prefix = view.prefix
            hasPhysicalRoot = view.hasPhysicalRoot
            self.front = front
            self.back = back
            self.index = index
        }

        @inline(__always)
        var start: Bytes.Index {
            bytes.startIndex
        }

        @inline(__always)
        var end: Bytes.Index {
            bytes.endIndex
        }

        @inline(__always)
        var hasRoot: Bool {
            if hasPhysicalRoot {
                return true
            }
            return prefix?.hasImplicitRoot ?? false
        }

        @inline(__always)
        var isFinished: Bool {
            front == .done || back == .done || front > back
        }

        @inline(__always)
        var inverseCount: Int {
            index - start
        }

        // Given the iteration so far, how much of the pre-State::Body path is left?
        var countBeforeBody: Int {
            let root = front <= .startDirectory && hasPhysicalRoot ? 1 : 0
            let currentDirectory = front <= .startDirectory && includeCurrentDirectory() ? 1 : 0
            return prefixRemaining() + root + currentDirectory
        }

        var prefixCount: Int {
            0
        }

        var prefixVerbatim: Bool {
            false
        }

        @inlinable
        @inline(__always)
        func prefixRemaining() -> Int {
            0
        }

        /// Should the normalized path include a leading . ?
        func includeCurrentDirectory() -> Bool {
            if hasRoot {
                return false
            }
            let start = bytes.index(bytes.startIndex, offsetBy: prefixRemaining())
            let remaining = bytes[start...]
            var iterator = remaining.makeIterator()
            switch (iterator.next(), iterator.next()) {
            case (.some(ASCII.period.rawValue), .none):
                return true
            case let (.some(ASCII.period.rawValue), .some(second)):
                return Path.isSeparator(second)
            default:
                return false
            }
        }
    }
}

extension Path.Components {
    /// Trim away repeated separators (i.e., empty components) on the left.
    @usableFromInline
    mutating func trimLeft() {
        while !bytes.isEmpty {
            index = start
            let (size, component) = parseNextComponent()
            if component != nil {
                return
            }
            bytes = bytes[(start + size)...]
        }
        index = start
    }

    /// Trim away repeated separators (i.e., empty components) on the right.
    @usableFromInline
    mutating func trimRight() {
        while bytes.count > countBeforeBody {
            index = end
            let (size, component) = parseNextComponentBack()
            if component != nil {
                return
            }
            bytes = bytes[..<(end - size)]
        }
        index = start
    }

    @inlinable
    @inline(__always)
    func toIterator() -> Path.ComponentView.Iterator {
        Path.ComponentView.Iterator(self)
    }

    @inlinable
    @inline(__always)
    func toBackIterator() -> Path.ComponentView.BackIterator {
        Path.ComponentView.BackIterator(self)
    }

    mutating func next() -> Path.Component? {
        while !isFinished {
            switch front {
            case .prefix where prefixCount > 0:
                // TODO: prefix
                break
            case .prefix:
                front = .startDirectory
            case .startDirectory:
                front = .body
                if hasPhysicalRoot {
                    assert(!bytes.isEmpty)
                    index += 1
                    return Path.Component.root()
                } else if includeCurrentDirectory() {
                    assert(!bytes.isEmpty)
                    index += 1
                    return Path.Component.current()
                }
            case .body where index < end:
                while index < end {
                    let (size, component) = parseNextComponent()
                    index += size
                    if let component = component {
                        return component
                    }
                }
            case .body:
                front = .done
            case .done:
#if DEBUG
                fatalError("unreachable")
#else
                return nil
#endif
            }
        }
        return nil
    }

    mutating func nextBack() -> Path.Component? {
        while !isFinished {
            switch back {
            case .body where inverseCount > countBeforeBody:
                while inverseCount > countBeforeBody {
                    let (size, component) = parseNextComponentBack()
                    index -= size
                    if let component = component {
                        return component
                    }
                }
            case .body:
                back = .startDirectory
            case .startDirectory:
                back = .prefix
                if hasPhysicalRoot {
                    index -= 1
                    return Path.Component.root()
                } else if includeCurrentDirectory() {
                    index -= 1
                    return Path.Component.current()
                }
            case .prefix where prefixCount > 0:
                back = .done
            case .prefix:
                back = .done
            case .done:
#if DEBUG
                fatalError("unreachable")
#else
                return nil
#endif
            }
        }
        return nil
    }

    func parseSingleComponent(_ bytes: Bytes) -> Path.Component? {
        if bytes.isEmpty {
            return nil
        }
        switch bytes {
        case ASCII.period.rawValue where prefixVerbatim:
            return Path.Component.current()
        case ASCII.period.rawValue:
            return nil
        case [ASCII.period.rawValue, ASCII.period.rawValue]:
            return Path.Component.parent()
        default:
            return Path.Component(.regular(bytes))
        }
    }

    func parseNextComponent() -> (Int, Path.Component?) {
        assert(front == .body)
        let extra: Int
        let bytes: Bytes
        if let i = self.bytes[index...].firstIndex(where: Path.isSeparator) {
            extra = 1
            bytes = self.bytes[index..<i]
        } else {
            extra = 0
            bytes = self.bytes[index...]
        }
        return (bytes.count + extra, parseSingleComponent(bytes))
    }

    func parseNextComponentBack() -> (Int, Path.Component?) {
        assert(back == .body)
        let extra: Int
        let bytes: Bytes
        let start = self.bytes.index(start, offsetBy: countBeforeBody)
        if let i = self.bytes[start..<index].lastIndex(where: Path.isSeparator) {
            extra = 1
            bytes = self.bytes[(i + 1)..<index]
        } else {
            extra = 0
            bytes = self.bytes[start..<index]
        }
        return (bytes.count + extra, parseSingleComponent(bytes))
    }
}

extension Path.Components {
    mutating func nextIndex() -> Path.Index {
        let result = nextComponent()
        front = result.state
        index = result.end
        return result
    }

    mutating func previousIndex() -> Path.Index {
        let result = previousComponent()
        index = result.start
        back = result.state
        return result
    }

    func nextComponent() -> Path.Index {
        _nextComponent(start: index, end: end, state: front)
    }

    func previousComponent() -> Path.Index {
        _previousComponent(start: start, end: index, state: back)
    }

    func isComponent(_ bytes: Bytes) -> Bool {
        if bytes.isEmpty {
            return false
        }
        switch bytes {
        case ASCII.period.rawValue:
            return prefixVerbatim
        default:
            return true
        }
    }

    @inline(__always)
    private func skipSeparators(index: inout Bytes.Index) {
        while Path.isSeparator(bytes[index]) {
            index += 1
        }
    }

    // TODO: rename
    @inline(__always)
    private func skipSeparatorsInverse(index: inout Bytes.Index) {
        while Path.isSeparator(bytes[index]) {
            index -= 1
        }
    }

    @inline(__always)
    private func nextComponentRange(_ index: Bytes.Index) -> (Int, Bool) {
        let extra: Int
        let bytes: Bytes
        if let i = self.bytes[index...].firstIndex(where: Path.isSeparator) {
            extra = 1
            bytes = self.bytes[index..<i]
        } else {
            extra = 0
            bytes = self.bytes[index...]
        }
        return (bytes.count + extra, isComponent(bytes))
    }

    @inline(__always)
    private func _nextComponent(start: Bytes.Index, end: Bytes.Index, state: Path.ParseState) -> Path.Index {
        var current = start
        var state = state
        while current < end {
            switch state {
            case .prefix:
                state = .startDirectory
                if hasPhysicalRoot {
                    assert(!bytes.isEmpty)
                    return Path.Index(start, current, current + 1, state) // "/"
                } else if includeCurrentDirectory() {
                    assert(!bytes.isEmpty)
                    return Path.Index(start, current, current + 1, state) // "."
                }
            case .startDirectory:
                state = .body
            case .body:
                while current < end {
                    skipSeparators(index: &current)
                    let (size, isComponent) = nextComponentRange(current)
                    if isComponent {
                        return Path.Index(start, current, current + size, state)
                    } else {
                        current += size
                    }
                }
                state = .done
            case .done:
                break
            }
        }
        assert(current == end)
        return Path.Index(start, end, .done)
    }

    @inline(__always)
    private func previousComponentRange(_ index: Bytes.Index) -> (Int, Int, Bool) {
        let extra: Int
        let bytes: Bytes
        let start = self.bytes.index(start, offsetBy: countBeforeBody)
        if let i = self.bytes[start..<index].lastIndex(where: Path.isSeparator) {
            extra = 1
            bytes = self.bytes[(i + 1)..<index]
        } else {
            extra = 0
            bytes = self.bytes[start..<index]
        }
        return (bytes.count, extra, isComponent(bytes))
    }

    @inline(__always)
    private func _previousComponent(start: Bytes.Index, end: Bytes.Index, state: Path.ParseState) -> Path.Index {
        var current = end
        var next = state
        while start < current {
            switch next {
            case .body:
                while (current - start) > countBeforeBody {
//                    skipSeparatorsInverse(index: &current)
                    let (size, offset, isComponent) = previousComponentRange(current)
                    current -= size
                    if isComponent {
//                        skipSeparatorsInverse(index: &current)
                        return Path.Index(current - offset, current, end, next)
                    } else {
                        current -= offset
                    }
                }
                next = .startDirectory
            case .startDirectory:
                if hasPhysicalRoot {
                    assert(!bytes.isEmpty)
                    return Path.Index(start, current - 1, current, next) // "/"
                } else if includeCurrentDirectory() {
                    assert(!bytes.isEmpty)
                    return Path.Index(start, current - 1, current, next) // "."
                }
                next = .prefix
            case .prefix:
                next = .done
            case .done:
                break
            }
        }
        assert(current == start)
        return Path.Index(start, start, end, .done)
    }
}

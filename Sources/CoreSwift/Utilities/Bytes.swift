#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

@frozen
public struct Bytes {
    public typealias Element = UInt8
    public typealias SubSequence = Bytes

    @usableFromInline
    typealias Pointer = UnsafeMutablePointer<UInt8>

    @usableFromInline
    private(set) var storage: Storage

    @_transparent
    @usableFromInline
    init(storage: Storage) {
        self.storage = storage
    }

    @inlinable
    @inline(__always)
    public init() {
        storage = Storage.empty()
    }

    @inlinable
    @inline(__always)
    public init(exactlyCapacity: Int) {
        storage = Storage.allocate(exactly: exactlyCapacity)
    }

    @inlinable
    @inline(__always)
    public init(capacity: Int) {
        storage = Storage.allocate(capacity: capacity)
    }

    @_transparent
    @usableFromInline
    mutating func isStorageUnique() -> Bool {
        isKnownUniquelyReferenced(&storage)
    }

    @_transparent
    @usableFromInline
    mutating func release() -> (Pointer, Int) {
        precondition(isStorageUnique())
        let start = storage.start
        let count = storage.count
        storage = Storage.empty()
        return (start, count)
    }

    @usableFromInline
    mutating func _reserveCapacity(_ n: Int, unique: Bool) {
        let makeCopy = storage.capacity < n || (unique && !isStorageUnique())
        if makeCopy {
            Storage.expand(&storage, capacity: n)
        }
    }

    @inline(__always)
    @usableFromInline
    static var null: UnsafeMutablePointer<UInt8> {
        cci_null_bytes()
    }
}

extension Bytes: Hashable {
    public func hash(into hasher: inout Hasher) {
        let buffer = UnsafeRawBufferPointer(start: UnsafeRawPointer(storage.start),
            count: storage.count)
        hasher.combine(bytes: buffer)
    }

    public static func ==(lhs: Bytes, rhs: Bytes) -> Bool {
        if lhs.storage === rhs.storage {
            return true
        }
        if lhs.storage.count != rhs.storage.count {
            return false
        }
        return memcmp(UnsafeRawPointer(lhs.storage.start), UnsafeRawPointer(rhs.storage.start),
            lhs.storage.count) == 0
    }

    public static func ==(lhs: Bytes, rhs: [UInt8]) -> Bool {
        if lhs.storage.count != rhs.count {
            return false
        }
        // TODO: should use to array?
        return lhs.toArray() == rhs
    }

    public static func ==(lhs: [UInt8], rhs: Bytes) -> Bool {
        if lhs.count != rhs.storage.count {
            return false
        }
        // TODO: should use to array?
        return lhs == rhs.toArray()
    }

    @inlinable
    public static func ~=(lhs: Bytes, rhs: [UInt8]) -> Bool {
        lhs == rhs
    }

    @inlinable
    public static func ~=(lhs: [UInt8], rhs: Bytes) -> Bool {
        lhs == rhs
    }

    @inlinable
    public static func ~=(lhs: Bytes, rhs: [ASCII]) -> Bool {
        lhs == rhs.map(\.rawValue)
    }

    @inlinable
    public static func ~=(lhs: [ASCII], rhs: Bytes) -> Bool {
        lhs.map(\.rawValue) == rhs
    }

    // TODO: is this useful?
    @inlinable
    public static func ~=(lhs: Bytes, rhs: UInt8) -> Bool {
        lhs.count == 1 && lhs.first == rhs
    }

    // TODO: switch use lhs for case first
    @inlinable
    public static func ~=(lhs: UInt8, rhs: Bytes) -> Bool {
        rhs ~= lhs
    }

    // Unfortunately swift compiler has a long term issue which cause:
    // switch bytes {
    // case ASCII.fullStop: <- error: Enum case 'period' not found in type 'Bytes'
    //     break
    // }
    //
    // Seealso: https://github.com/apple/swift/issues/50331
    // https://forums.swift.org/t/buggy-name-lookup-behavior-in-pattern-matching/66460

    /// NOTE:
    ///
    /// ```swift
    /// switch bytes {
    /// case ASCII.null.self // <- note the `.self`
    /// }
    /// ```
    @inlinable
    public static func ~=(lhs: Bytes, rhs: ASCII) -> Bool {
        lhs ~= rhs.rawValue
    }

    /// NOTE:
    ///
    /// ```swift
    /// switch bytes {
    /// case ASCII.null.self // <- note the `.self`
    /// }
    /// ```
    @inlinable
    public static func ~=(lhs: ASCII, rhs: Bytes) -> Bool {
        lhs.rawValue ~= rhs
    }
}

extension Bytes {
    public init<S>(_ elements: S) where S: Sequence, S.Element == UInt8 {
        let storage = Storage.from(elements) ??
            elements._copyToContiguousArray().withUnsafeBufferPointer(Storage.from)
        self.storage = storage
    }

    public init(repeating value: UInt8, count: Int) {
        storage = Storage.allocate(size: count, capacity: count) { pointer in
            pointer.initialize(repeating: value, count: count)
        }
    }

    @inlinable
    @inline(__always)
    public static func empty() -> Bytes {
        Bytes()
    }

    public func withUnsafeBuffer<Result>(_ body: (UnsafeBufferPointer<UInt8>) throws -> Result) rethrows -> Result {
        if _slowPath(storage.start == Bytes.null) {
            return try body(UnsafeBufferPointer(start: nil, count: 0))
        }
        let buffer = UnsafeBufferPointer(start: storage.start, count: storage.count)
        return try body(buffer)
    }

    public func withUnsafeBytes<Result>(_ body: (UnsafeRawBufferPointer) throws -> Result) rethrows -> Result {
        if _slowPath(storage.start == Bytes.null) {
            return try body(UnsafeRawBufferPointer(start: nil, count: 0))
        }
        let buffer = UnsafeBufferPointer(start: storage.start, count: storage.count)
        return try body(UnsafeRawBufferPointer(buffer))
    }

    public mutating func withUnsafeMutableBuffer<Result>(
        _ body: (inout UnsafeMutableBufferPointer<UInt8>) throws -> Result
    ) rethrows -> Result {
        _reserveCapacity(capacity, unique: true)
        var buffer: UnsafeMutableBufferPointer<UInt8>
        if _slowPath(storage.start == Bytes.null) {
            buffer = UnsafeMutableBufferPointer(start: nil, count: 0)
        } else {
            buffer = UnsafeMutableBufferPointer(start: storage.start, count: storage.count)
        }
        let old = buffer
        let result = try body(&buffer)
        assert(old.baseAddress == buffer.baseAddress && old.count == buffer.count,
            "replacing the buffer is not allowed")
        return result
    }

    public mutating func withUnsafeMutableBytes<Result>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> Result
    ) rethrows -> Result {
        _reserveCapacity(capacity, unique: true)
        if _slowPath(storage.start == Bytes.null) {
            return try body(UnsafeMutableRawBufferPointer(start: nil, count: 0))
        }
        let buffer = UnsafeMutableRawBufferPointer(start: storage.start, count: storage.count)
        return try body(buffer)
    }

    public mutating func withUnsafeMutableStorage<Result>(
        _ body: (_ start: UnsafeMutablePointer<UInt8>, _ end: UnsafeMutablePointer<UInt8>,
            _ current: inout UnsafeMutablePointer<UInt8>) throws -> Result
    ) rethrows -> Result? {
        if _slowPath(storage.start == Bytes.null) {
            return nil
        }
        _reserveCapacity(capacity, unique: true)
        return try storage.use { start, end, current in
            try body(start, end, &current)
        }
    }
}

extension Bytes: CustomStringConvertible {
    public var description: String {
        toArray().description
    }
}

extension Bytes: Sequence {
    @inlinable
    @inline(__always)
    public var underestimatedCount: Int {
        count
    }

    @inlinable
    @inline(__always)
    public __consuming func makeIterator() -> Iterator {
        Iterator(storage: storage)
    }

    @inlinable
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<UInt8>) throws -> R
    ) rethrows -> R? {
        if storage.start == Bytes.null {
            return nil
        }
        let buffer = UnsafeBufferPointer(start: storage.start, count: storage.count)
        return try body(buffer)
    }
}

extension Bytes: MutableCollection {
    @inlinable
    public var startIndex: Index {
        Index(storage.start)
    }

    @inlinable
    public var endIndex: Index {
        Index(storage.current)
    }

    @inlinable
    var currentIndex: Index {
        Index(storage.current)
    }

    @inlinable
    public var isEmpty: Bool {
        storage.current == storage.start
    }

    @inlinable
    public var count: Int {
        storage.count
    }

    @inlinable
    public var capacity: Int {
        storage.capacity
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        Index(i.data.advanced(by: distance))
    }

    @inlinable
    public func formIndex(after i: inout Index) {
        i.data += 1
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        // NOTE: Range checks are not performed here, because it is done later by
        // the subscript function.
        let n = limit.data.distance(to: i.data)
        if distance > 0 ? (n >= 0 && n < distance) : (n <= 0 && distance < n) {
            return nil
        }
        return Index(i.data.advanced(by: distance))
    }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        start.data.distance(to: end.data)
    }

    @inlinable
    public func _failEarlyRangeCheck(_ index: Index, bounds: Range<Index>) {
        // NOTE: This method is a no-op for performance reasons.
    }

    @inlinable
    public func _failEarlyRangeCheck(_ index: Index, bounds: ClosedRange<Index>) {
        // NOTE: This method is a no-op for performance reasons.
    }

    @inlinable
    public func _failEarlyRangeCheck(_ range: Range<Index>, bounds: Range<Index>) {
        // NOTE: This method is a no-op for performance reasons.
    }

    @inlinable
    public func index(after i: Index) -> Index {
        Index(i.data.advanced(by: 1))
    }

    @inlinable
    public func swapAt(_ i: Index, _ j: Index) {
        precondition(storage.start <= i.data && i.data < storage.end,
            "Invalid index")
        precondition(storage.start <= j.data && j.data < storage.end,
            "Invalid index")
        let t = i.data.pointee
        i.data.update(from: UnsafePointer(j.data), count: 1)
        j.data.update(repeating: t, count: 1)
    }

    @inlinable
    public subscript(position: Index) -> UInt8 {
        get {
            precondition(storage.start <= position.data && position.data < storage.end,
                "Invalid index")
            return position.data.pointee
        }
        _modify {
            precondition(storage.start <= position.data && position.data < storage.end,
                "Invalid index")
            // & pointee??
            yield &position.data.pointee
        }
    }

    @inlinable
    public subscript(position: Int) -> UInt8 {
        get {
            precondition(position >= 0 && position < storage.count,
                "Invalid index")
            return (startIndex + position).data.pointee
        }
        _modify {
            precondition(position >= 0 && position < storage.count,
                "Invalid index")
            // & pointee??
            yield &(startIndex + position).data.pointee
        }
    }

    public subscript(bounds: Range<Index>) -> Bytes {
        get {
            precondition(bounds.lowerBound >= startIndex, "Out of index")
            precondition(bounds.upperBound <= endIndex, "Out of index")
            let start = bounds.lowerBound.data
            let end = bounds.upperBound.data
            let current = storage.current < end ? storage.current : end
            let next = Storage(origin: storage, start: start, end: end, current: current)
            return Bytes(storage: next)
        }
        set {
            replaceSubrange(bounds, with: newValue)
        }
    }
}

extension Bytes: RandomAccessCollection {
    public func formIndex(before i: inout Index) {
        i.data -= 1
    }

    @inlinable
    public func index(before i: Index) -> Index {
        Index(i.data + 1)
    }
}

extension Bytes: RangeReplaceableCollection {
    @inlinable
    public mutating func unsafeAppend(_ count: Int, _ method: (UnsafeMutablePointer<UInt8>) -> Void) {
        _reserveCapacity(storage.count + count, unique: true)
        storage.withCurrent { current in
            method(current)
            current += count
        }
    }

    @inlinable
    public mutating func append(_ newElement: UInt8) {
        _reserveCapacity(storage.count + 1, unique: true)
        storage.withCurrent { current in
            current.initialize(to: newElement)
            current += 1
        }
    }

    @inlinable
    public mutating func append(_ elements: UInt8...) {
        _reserveCapacity(storage.count + elements.count, unique: true)
        let success = elements.withContiguousStorageIfAvailable { pointer -> Bool in
            storage.copy(from: pointer, position: endIndex.data - 1)
            return true
        }
        if success == true {
            return
        }
        storage.withCurrent { current in
            for element in elements {
                current.initialize(to: element)
            }
            current += 1
        }
    }

    @inlinable
    public mutating func append(_ other: Bytes) {
        let size = other.count
        _reserveCapacity(count + size, unique: true)
        storage.withCurrent { current in
            current.initialize(from: other.storage.start, count: size)
            current += size
        }
    }

    @inlinable
    public mutating func append(_ other: UnsafeMutableBufferPointer<UInt8>) {
        append(UnsafeBufferPointer(other))
    }

    @inlinable
    public mutating func append(_ other: UnsafeBufferPointer<UInt8>) {
        guard other.count > 0, let base = other.baseAddress else {
            return
        }
        let size = other.count
        _reserveCapacity(count + size, unique: true)
        storage.withCurrent { current in
            current.initialize(from: base, count: size)
            current += size
        }
    }

    public mutating func append<S>(contentsOf newElements: S) where S: Sequence, S.Element == UInt8 {
        let oldCount = storage.count
        let newElementsCount = newElements.underestimatedCount
        _reserveCapacity(oldCount + newElementsCount, unique: true)
        let buffer = UnsafeMutableBufferPointer(start: storage.current, count: storage.capacity - oldCount)
        var (i, n) = buffer.initialize(from: newElements)
        // trap on underflow from the sequence's underestimate:
        let writtenCount = buffer.distance(from: buffer.startIndex, to: n)
        precondition(newElementsCount <= writtenCount,
            "newElements.underestimatedCount was an overestimate")
        // can't check for overflow as sequences can underestimate

        if _slowPath(n == buffer.endIndex) {
            // A shortcut for appending an Array: If newElements is an Array then it's
            // guaranteed that buf.initialize(from: newElements) already appended all
            // elements. It reduces code size, because the following code
            // can be removed by the optimizer by constant folding this check in a
            // generic specialization.
            if S.self == [Element].self {
                return
            }

            // there may be elements that didn't fit in the existing buffer,
            // append them in slow sequence-only mode
            var next = i.next()
            while next != nil {
                if storage.count == storage.capacity {
                    Storage.expand(&storage)
                }
                while let value = next, storage.current < storage.end {
                    storage.withCurrent { current in
                        current += 1
                        current.initialize(to: value)
                    }
                    next = i.next()
                }
            }
        }
    }

    public mutating func insert(_ newElement: UInt8, at i: Index) {
        precondition(storage.start >= i.data && i.data <= storage.current, "Out of index")
        if i.data == storage.current {
            append(newElement)
            return
        }
        // TODO: move once
        _reserveCapacity(count + 1, unique: true)
        // start <= i < current < end
        storage.with { start, end, current in
            let move = i.data + 1
            move.moveUpdate(from: i.data, count: current - i.data)
            i.data.initialize(to: newElement)
            current += 1
        }
    }

    public mutating func reserveCapacity(_ n: Int) {
        _reserveCapacity(n, unique: false)
    }

    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
        where C: Collection, C.Element == UInt8 {
        // swift/stdlib/public/core/ArrayBufferProtocol.swift replaceSubrange
        precondition(subrange.lowerBound >= startIndex, "Out of index")
        precondition(subrange.upperBound <= endIndex, "Out of index")

        let eraseCount = subrange.count
        let insertCount = newElements.count
        let growth = insertCount - eraseCount
        _reserveCapacity(storage.count + growth, unique: true)
        storage.replaceSubrange(subrange, with: insertCount, elements: newElements)
    }

    @inlinable
    @inline(__always)
    @discardableResult
    mutating func _remove(at i: Pointer) -> UInt8 {
        if isStorageUnique() {
            return storage.remove(at: i)
        }
        let (result, next) = storage.removeUseCopy(at: i)
        storage = next
        return result
    }

    @inlinable
    @inline(__always)
    mutating func _remove(at i: Pointer, count: Int) {
        if isStorageUnique() {
            storage.remove(at: i, count: count)
        } else {
            storage = storage.removeUseCopy(at: i, count: count)
        }
    }

    @inlinable
    @discardableResult
    public mutating func remove(at i: Int) -> UInt8 {
        remove(at: startIndex + i)
    }

    @inlinable
    @discardableResult
    public mutating func remove(at i: Index) -> UInt8 {
        precondition(i >= startIndex && i < endIndex, "Out of index")
        return _remove(at: i.data)
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        if keepCapacity {
            if isStorageUnique() {
                storage.clear()
            } else {
                storage = Storage.allocate(capacity: storage.capacity)
            }
        } else {
            storage = Storage.empty()
        }
    }

    @inlinable
    @discardableResult
    public mutating func removeFirst() -> UInt8 {
        precondition(storage.count > 1, "Bytes is empty")
        return _remove(at: startIndex.data)
    }

    public mutating func removeFirst(_ k: Int) {
        if _slowPath(k == 0) {
            return
        }
        precondition(k >= 0, "Number of elements to remove should be non-negative")
        precondition(k <= count, "Not enough elements to remove")
        _remove(at: startIndex.data, count: k)
    }
}

extension Bytes: BidirectionalCollection {
    @inlinable
    public mutating func popLast() -> UInt8? {
        if storage.count < 1 {
            return nil
        }
        return _remove(at: endIndex.data - 1)
    }

    @inlinable
    @discardableResult
    public mutating func removeLast() -> UInt8 {
        precondition(storage.count > 1, "Bytes is empty")
        return _remove(at: endIndex.data - 1)
    }

    public mutating func removeLast(_ k: Int) {
        if _slowPath(k == 0) {
            return
        }
        precondition(k >= 0, "Number of elements to remove should be non-negative")
        precondition(k <= count, "Not enough elements to remove")
        _remove(at: endIndex.data - 1, count: k)
    }
}

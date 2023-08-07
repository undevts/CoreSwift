#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

/// A _debugPrecondition check that `i` has exactly reached the end of
/// `s`.  This test is never used to ensure memory safety; that is
/// always guaranteed by measuring `s` once and re-using that value.
@inlinable
internal func _expectEnd<C: Collection>(of s: C, is i: C.Index) {
#if DEBUG
    precondition(i == s.endIndex,
        "invalid Collection: count differed in successive traversals")
#endif
}

extension Bytes {
    @usableFromInline
    class Storage {
        @usableFromInline
        fileprivate(set) var origin: Storage?
        @usableFromInline
        fileprivate(set) var start: Pointer
        @usableFromInline
        fileprivate(set) var end: Pointer
        @usableFromInline
        fileprivate(set) var current: Pointer

        @inlinable
        @inline(__always)
        var capacity: Int {
            end - start
        }

        @inlinable
        @inline(__always)
        var root: Storage {
            var result = origin
            while let next = result?.origin {
                result = next
            }
            return result ?? self
        }

        @inlinable
        init(origin: Storage?, start: Pointer, end: Pointer, current: Pointer) {
            precondition(start <= current && current <= end)
            self.origin = origin?.root
            self.start = start
            self.end = end
            self.current = current
        }

        @inlinable
        @inline(__always)
        convenience init(start: Pointer, end: Pointer) {
            self.init(origin: nil, start: start, end: end, current: start)
        }

        @inlinable
        @inline(__always)
        convenience init(start: Pointer, end: Pointer, current: Pointer) {
            self.init(origin: nil, start: start, end: end, current: current)
        }

        deinit {
            deallocate()
        }

        @inlinable
        @inline(__always)
        func deallocate() {
            if origin == nil && start != Bytes.null {
                start.deallocate()
            }
        }

        @inlinable
        @inline(__always)
        func with(_ mutation: (Pointer, Pointer, inout Pointer) -> Void) {
            mutation(start, end, &current)
        }

        @inlinable
        @inline(__always)
        func use<Result>(_ mutation: (Pointer, Pointer, inout Pointer) throws -> Result) rethrows -> Result {
            try mutation(start, end, &current)
        }

        @inlinable
        @inline(__always)
        func withCurrent(_ mutation: (inout Pointer) -> Void) {
            mutation(&current)
        }

        @inlinable
        func replaceSubrange<C>(_ subrange: Range<Index>, with insertCount: Int,
            elements newValues: __owned C) where C: Collection, C.Element == UInt8 {
            let eraseCount = subrange.count
            let growth = insertCount - eraseCount

            let oldTailIndex = subrange.upperBound
            let oldTailStart = oldTailIndex.data
            let newTailIndex = oldTailIndex + growth
            let newTailStart = oldTailStart + growth
            let tailCount = current - subrange.upperBound.data

            if growth > 0 {
                // Slide the tail part of the buffer forwards, in reverse order
                // so as not to self-clobber.
                newTailStart.moveInitialize(from: oldTailStart, count: tailCount)

                // Assign over the original subrange
                var i = newValues.startIndex
                for j in subrange {
                    j.data.initialize(to: newValues[i])
                    newValues.formIndex(after: &i)
                }
                // Initialize the hole left by sliding the tail forward
                for j in oldTailIndex..<newTailIndex {
                    j.data.initialize(to: newValues[i])
                    newValues.formIndex(after: &i)
                }
                _expectEnd(of: newValues, is: i)
            } else { // We're not growing the buffer
                // Assign all the new elements into the start of the subrange
                var i = subrange.lowerBound
                var j = newValues.startIndex
                for _ in 0..<insertCount {
                    i.data.initialize(to: newValues[j])
                    i += 1
                    newValues.formIndex(after: &j)
                }
                _expectEnd(of: newValues, is: j)

                // If the size didn't change, we're done.
                if growth == 0 {
                    return
                }

                // Move the tail backward to cover the shrinkage.
                let shrinkage = -growth
                if tailCount > shrinkage {   // If the tail length exceeds the shrinkage

                    // Assign over the rest of the replaced range with the first
                    // part of the tail.
                    newTailStart.moveUpdate(from: oldTailStart, count: shrinkage)

                    // Slide the rest of the tail back
                    oldTailStart.moveInitialize(
                        from: oldTailStart + shrinkage, count: tailCount - shrinkage)
                } else {                      // Tail fits within erased elements
                    // Assign over the start of the replaced range with the tail
                    newTailStart.moveUpdate(from: oldTailStart, count: tailCount)

                    // Destroy elements remaining after the tail in subrange
                    (newTailStart + tailCount).deinitialize(
                        count: shrinkage - tailCount)
                }
            }
        }

        @inlinable
        @inline(__always)
        func remove(at index: Pointer) -> UInt8 {
            // precondition(index >= start && index < end, "Out of index")
            let result = index.pointee
//            if end - index > 1 {
//                let from = index + 1
//                index.assign(from: from, count: current - from)
//            }
//            current -= 1
            remove(at: index, count: 1)
            return result
        }

        @inlinable
        @inline(__always)
        func removeUseCopy(at index: Pointer) -> (UInt8, Storage) {
            // precondition(index >= start && index < end, "Out of index")
            let result = index.pointee
            let next = removeUseCopy(at: index, count: 1)
//            let count = count
//            let next = Storage.allocate(capacity: capacity)
//            next.current += count - 1
//
//            if end - index == 1 { // remove last
//                next.start.assign(from: start, count: count - 1)
//            } else if index == start {
//                next.start.assign(from: start + 1, count: count - 1)
//            } else {
//                let n = index - start
//                let temp = next.start + n
//                next.start.assign(from: start, count: n)
//                temp.assign(from: index + 1, count: count - 1 - n)
//            }
            return (result, next)
        }

        @inlinable
        func remove(at index: Pointer, count: Int) {
            // precondition(index >= start && index < end, "Out of index")
            if end - index > count {
                let from = index + count
                index.update(from: from, count: current - from)
            }
            current -= count
        }

        @inlinable
        func removeUseCopy(at index: Pointer, count: Int) -> Storage {
            // precondition(index >= start && index < end, "Out of index")
//            let count = count
            let next = Storage.allocate(capacity: capacity)
            let size = Storage.copy(from: self, position: next.start, start: start, current: index, end: end)
            next.current += size

//            if end - index == 1 { // remove last
//                next.start.assign(from: start, count: count - 1)
//            } else if index == start {
//                next.start.assign(from: start + 1, count: count - 1)
//            } else {
//                let n = index - start
//                let temp = next.start + n
//                next.start.assign(from: start, count: n)
//                temp.assign(from: index + 1, count: count - 1 - n)
//            }
            return next
        }
    }
}

extension Bytes {
    final class BufferStorage<Buffer>: Storage where Buffer: BytesBuffer {
        private var buffer: Buffer

        @inlinable
        init(buffer: Buffer) {
            self.buffer = buffer
            // Can not use buffer.start() here.
            super.init(origin: nil, start: Bytes.null, end: Bytes.null, current: Bytes.null)
            start = self.buffer.start()
            end = self.buffer.end()
            current = start
        }

        override var capacity: Int {
            buffer.capacity
        }

        override func deallocate() {
            // Nothing to deallocate.
        }
    }
}

extension Bytes.Storage {
    @inlinable
    @inline(__always)
    var count: Int {
        current - start
    }

    @inline(__always)
    private func copy(from storage: Bytes.Storage) {
        let count = storage.count
        start.update(from: storage.start, count: count)
        current = start.advanced(by: count)
    }

    @inline(__always)
    func copy(from source: UnsafePointer<UInt8>, count: Int) {
        assert(UnsafePointer(start) != source &&
            (UnsafePointer(start) < source || UnsafePointer(start) > source.advanced(by: count)))
        start.update(from: source, count: count)
        current = start.advanced(by: count)
    }

    @inline(__always)
    @usableFromInline
    func copy(from source: UnsafeBufferPointer<UInt8>, position: Bytes.Pointer) {
        guard source.count > 0, let base = source.baseAddress else {
            return
        }
        let count = source.count
        position.update(from: base, count: count)
        current += count
    }

    @inlinable
    @inline(__always)
    static func copy(from storage: Bytes.Storage, position: Bytes.Pointer,
        start: Bytes.Pointer, current: Bytes.Pointer, end: Bytes.Pointer) -> Int {

        // storage.start <= start <= current <= end <= storage.end
        var count = current - start
        if count > 0 {
            position.update(from: start, count: count)
        }
        let next = position + count
        count = end - current
        if count > 0 {
            next.update(from: current, count: count)
        }
        return end - start
    }

    @inline(__always)
    func clear() {
        current = start
    }

    static func expand(_ storage: inout Bytes.Storage, capacity: Int) {
        let next = Bytes.Storage.allocate(capacity: max(capacity, storage.count))
        next.copy(from: storage)
        storage = next
    }

    static func expand(_ storage: inout Bytes.Storage) {
        let next: Bytes.Storage
        switch storage.capacity {
        case 0:
            next = Bytes.BufferStorage(buffer: cci_buffer_32())
        case 32:
            next = Bytes.BufferStorage(buffer: cci_buffer_64())
        case 64:
            next = Bytes.BufferStorage(buffer: cci_buffer_128())
        case 128:
            next = Bytes.BufferStorage(buffer: cci_buffer_256())
        case 256:
            next = Bytes.BufferStorage(buffer: cci_buffer_512())
        case 512:
            next = Bytes.BufferStorage(buffer: cci_buffer_1024())
        case 1024:
            next = Bytes.BufferStorage(buffer: cci_buffer_2048())
        case 2048:
            next = Bytes.BufferStorage(buffer: cci_buffer_4096())
        default:
            next = allocateMany(capacity: storage.capacity * 2)
        }
        next.copy(from: storage)
        storage = next
    }

    @inlinable
    @inline(__always)
    static func empty() -> Bytes.Storage {
        Bytes.Storage(start: Bytes.null, end: Bytes.null)
    }

    @inline(__always)
    @usableFromInline
    static func from(_ pointer: UnsafeRawBufferPointer) -> Bytes.Storage {
        guard pointer.count > 0,
              let base = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
            return Bytes.Storage.empty()
        }
        let count = pointer.count
        let result = Bytes.Storage.allocate(capacity: count)
        result.copy(from: base, count: count)
        return result
    }

    @inline(__always)
    @usableFromInline
    static func from(_ pointer: UnsafeBufferPointer<UInt8>) -> Bytes.Storage {
        guard pointer.count > 0, let base = pointer.baseAddress else {
            return Bytes.Storage.empty()
        }
        let count = pointer.count
        let result = Bytes.Storage.allocate(capacity: count)
        result.copy(from: base, count: count)
        return result
    }

    @usableFromInline
    static func allocate(capacity: Int) -> Bytes.Storage {
        precondition(capacity >= 0)
        if _slowPath(capacity < 1) {
            return empty()
        }
        if _fastPath(capacity < 4097) {
            switch capacity {
            case 0...32:
                return Bytes.BufferStorage(buffer: cci_buffer_32())
            case 33...64:
                return Bytes.BufferStorage(buffer: cci_buffer_64())
            case 65...128:
                return Bytes.BufferStorage(buffer: cci_buffer_128())
            case 129...256:
                return Bytes.BufferStorage(buffer: cci_buffer_256())
            case 257...512:
                return Bytes.BufferStorage(buffer: cci_buffer_512())
            case 513...1024:
                return Bytes.BufferStorage(buffer: cci_buffer_1024())
            case 1025...2048:
                return Bytes.BufferStorage(buffer: cci_buffer_2048())
            default:
                return Bytes.BufferStorage(buffer: cci_buffer_4096())
            }
        }
        let start = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        return Bytes.Storage(start: start, end: start.advanced(by: capacity),
            current: start)
    }

    @usableFromInline
    static func allocate(exactly capacity: Int) -> Bytes.Storage {
        precondition(capacity >= 0)
        switch capacity {
        case 0:
            return empty()
        case 32:
            return Bytes.BufferStorage(buffer: cci_buffer_32())
        case 64:
            return Bytes.BufferStorage(buffer: cci_buffer_64())
        case 128:
            return Bytes.BufferStorage(buffer: cci_buffer_128())
        case 256:
            return Bytes.BufferStorage(buffer: cci_buffer_256())
        case 512:
            return Bytes.BufferStorage(buffer: cci_buffer_512())
        case 1024:
            return Bytes.BufferStorage(buffer: cci_buffer_1024())
        case 2048:
            return Bytes.BufferStorage(buffer: cci_buffer_2048())
        case 4096:
            return Bytes.BufferStorage(buffer: cci_buffer_4096())
        default:
            let start = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
            return Bytes.Storage(start: start, end: start.advanced(by: capacity),
                current: start)
        }
    }

    static func allocate(size: Int, capacity: Int, fulfill: (Bytes.Pointer) -> Void) -> Bytes.Storage {
        precondition(capacity >= size)
        let storage = Bytes.Storage.allocate(capacity: capacity)
        storage.current = storage.start.advanced(by: size)
        fulfill(storage.start)
        return storage
    }

    private static func allocateMany(capacity: Int) -> Bytes.Storage {
        precondition(capacity > 0)
        let start = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        return Bytes.Storage(start: start, end: start.advanced(by: capacity),
            current: start)
    }

    @inline(__always)
    @usableFromInline
    static func from<S>(_ data: S) -> Bytes.Storage? where S: Sequence, S.Element == UInt8 {
        data.withContiguousStorageIfAvailable(Bytes.Storage.from)
    }
}

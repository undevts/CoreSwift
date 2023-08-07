extension Buffer {
    @usableFromInline
    final class Storage {
        let size = MemoryLayout<T>.stride

        @usableFromInline
        fileprivate(set) var origin: Storage?
        @usableFromInline
        fileprivate(set) var start: Pointer
        @usableFromInline
        fileprivate(set) var end: Pointer
        @usableFromInline
        fileprivate(set) var current: Pointer

        @inlinable
        init(origin: Storage?, start: Pointer, end: Pointer, current: Pointer) {
            self.origin = origin
            self.start = start
            self.end = end
            self.current = current
        }

        @inline(__always)
        convenience init(start: Pointer, end: Pointer) {
            self.init(origin: nil, start: start, end: end, current: start)
        }

        @inline(__always)
        convenience init(start: Pointer, end: Pointer, current: Pointer) {
            self.init(origin: nil, start: start, end: end, current: current)
        }

        deinit {
            deallocate()
        }

        func deallocate() {
            if origin == nil && start != Bytes.null {
                start.deinitialize(count: count)
                start.deallocate()
            }
        }
    }
}

extension Buffer.Storage {
    @inlinable
    @inline(__always)
    var count: Int {
        current - start
    }
}

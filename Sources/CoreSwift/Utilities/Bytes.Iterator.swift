extension Bytes {
    @frozen
    public struct Iterator: IteratorProtocol {
        public typealias Element = UInt8

        @usableFromInline
        let storage: Storage
        @usableFromInline
        private(set) var current: Pointer

        @usableFromInline
        init(storage: Storage) {
            self.storage = storage
            current = storage.start
        }

        public mutating func next() -> UInt8? {
            if current >= storage.current {
                return nil
            }
            let result = current.pointee
            current += 1
            return result
        }
    }
}

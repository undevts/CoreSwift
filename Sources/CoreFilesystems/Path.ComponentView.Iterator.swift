#if SWIFT_PACKAGE
import CoreSwift
#endif

extension Path.ComponentView {
    @frozen
    public struct Iterator: IteratorProtocol {
        public typealias Element = Path.Component

        @usableFromInline
        var iterator: Path.Components

        @inlinable
        init(_ iterator: Path.Components) {
            self.iterator = iterator
        }

        public mutating func next() -> Path.Component? {
            iterator.next()
        }
    }

    @frozen
    public struct BackIterator: IteratorProtocol {
        public typealias Element = Path.Component

        @usableFromInline
        var iterator: Path.Components

        @inlinable
        init(_ iterator: Path.Components) {
            self.iterator = iterator
        }

        public mutating func next() -> Path.Component? {
            iterator.nextBack()
        }
    }
}
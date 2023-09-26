extension RangeReplaceableCollection {
    /// Replaces an element at the specified index with the given element.
    ///
    /// - Parameters:
    ///   - index: The position of the element to replace.
    /// index must be greater than or equal to `startIndex` and less than `endIndex`.
    ///   - element: The element to replace.
    @inlinable
    public mutating func replace(at index: Index, with element: Element) {
        // [1], 0..<0 => [2, 1]
        // [1], 0..<1 => [2]
        // [1], 1..<1 => [1, 2]
        // [1], 0...0 => [2]
        // [1], 1...1 => ERROR
#if DEBUG
        precondition(index >= startIndex && index < endIndex)
#else
        guard index >= startIndex && index < endIndex else {
            return
        }
#endif
        replaceSubrange(index...index, with: [element])
    }

    /// A non-mutating version ``replace(at:with)``.
    ///
    /// - Parameters:
    ///   - index: The position of the element to replace.
    /// index must be greater than or equal to `startIndex` and less than `endIndex`.
    ///   - element: The element to replace.
    @inlinable
    public func replaced(at index: Index, with element: Element) -> Self {
        var this = self
        this.replace(at: index, with: element)
        return this
    }
}

extension RangeReplaceableCollection where Element: Equatable {
    @inlinable
    @discardableResult
    public mutating func removeFirst(of value: Element) -> Element? {
        guard let index = firstIndex(of: value) else {
            return nil
        }
        return remove(at: index)
    }
}

extension BidirectionalCollection {
    /// Returns the last non-null value produced by `transform` function being applied
    /// to elements of this collection in iteration order, or `nil` if no non-null value was produced.
    ///
    /// - Parameter transform: A mapping closure.
    /// - Returns: The last non-null result of the given closure. If all elements in the collection
    /// after transform is `nil`, returns `nil`.
    @inlinable
    public func lastOf<R>(_ transform: (Element) throws -> R?) rethrows -> R? {
        for item in reversed() {
            if let result = try transform(item) {
                return result
            }
        }
        return nil
    }
}

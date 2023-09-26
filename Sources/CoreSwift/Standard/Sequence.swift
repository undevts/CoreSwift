extension Sequence {
    /// Returns an array containing the non-nil elements.
    ///
    /// - Returns: An array of the non-nil elements.
    @inlinable
    @inline(__always)
    func mapNotNil<Result>() -> [Result] where Element == Optional<Result> {
        compactMap(Function.identity)
    }
}

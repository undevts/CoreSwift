extension Collection {
    /// Splits this collection into an array of sequences each not exceeding the given `size`.
    ///
    /// ```swift
    /// let array = ["h", "i", "l", "l", "o"]
    /// let chunked = array.chunked(size: 2)
    /// // [ArraySlice(["h", "i"]), ArraySlice(["l", "l"]), ArraySlice(["o"])]
    /// ```
    /// - Note: The last sequence in the resulting array may have fewer elements than the given `size`.
    ///
    /// - Parameter size: The number of elements to take in each array,
    /// must be positive and can be greater than the number of elements in this collection.
    @inlinable
    public func chunked(size: Int) -> [SubSequence] {
        if isEmpty || size < 1 {
            return []
        }
        var result: [SubSequence] = []
        var start = startIndex
        var end = index(start, offsetBy: size)
        while end <= endIndex {
            let sequence: SubSequence = self[start..<end]
            result.append(sequence)
            start = end
            end = index(start, offsetBy: size)
        }
        if start != endIndex {
            let sequence: SubSequence = self[start..<endIndex]
            result.append(sequence)
        }
        return result
    }

    /// A Boolean value indicating whether the collection is **not** empty.
    /// Same as `!isEmpty`.
    @inlinable
    @inline(__always)
    public var isNotEmpty: Bool {
        !isEmpty
    }

    /// Returns an element at the given index or returns `nil` if the index is out of bounds of this collection.
    ///
    /// - Parameter index: The position of the element to access.
    @inlinable
    @inline(__always)
    public func at(_ index: Index) -> Element? {
        guard index >= startIndex && index < endIndex else {
            return nil
        }
        return self[index]
    }

    /// Returns an element at the given index or returns `default` value
    /// if the index is out of bounds of this collection.
    ///
    /// - Parameters:
    ///   - index: The position of the element to access.
    ///   - default: A function provides a "default" value.
    @inlinable
    @inline(__always)
    public func at(_ index: Index, or `default`: @autoclosure () -> Element) -> Element {
        guard index >= startIndex && index < endIndex else {
            return `default`()
        }
        return self[index]
    }

    /// Returns an array containing, in order, the elements of the collection that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes an element of the collection as its argument and the index
    /// of an element, returns a bool value indicating whether the element should be included in the
    /// returned array.
    /// - Returns: An array of the elements that `isIncluded` allowed.
    @inlinable
    public func filterIndexed(_ isIncluded: (Element, Index) throws -> Bool) rethrows -> [Element] {
        if isEmpty {
            return []
        }
        var result: [Element] = []
        var i = startIndex
        repeat {
            if try isIncluded(self[i], i) {
                result.append(self[i])
            }
            i = index(after: i)
        } while i < endIndex
        return result
    }

    /// Returns an array containing the results of mapping the given closure over the collection’s elements.
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this collection and the index
    /// of an element, returns a transformed value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this collection.
    @inlinable
    public func mapIndexed<T>(_ transform: (Element, Index) throws -> T) rethrows -> [T] {
        if isEmpty {
            return []
        }
        var result: [T] = []
        var i = startIndex
        repeat {
            let t = try transform(self[i], i)
            result.append(t)
            i = index(after: i)
        } while i < endIndex
        return result
    }

    /// Returns the result of combining the elements of the collection using the given closure.
    ///
    /// - Parameters:
    ///   - collection: A collection stores the transformed elements.
    ///   - transform: A mapping closure. `transform` accepts an element of this collection as its parameter,
    /// returns a transformed value which type same as `Collection.Element`.
    /// - Returns: The final result. If the collection has no elements, the result is `collection`.
    @inlinable
    public func map<C>(into collection: C, transform: (Element) throws -> C.Element) rethrows -> C
        where C: RangeReplaceableCollection {
        var collection = collection
        for element in self {
            collection.append(try transform(element))
        }
        return collection
    }


    /// Returns the result of combining the elements of the collection using the given closure.
    ///
    /// - Parameters:
    ///   - collection: A collection stores the transformed elements.
    ///   - transform: A mapping closure. `transform` accepts an element of this collection as its parameter,
    /// returns a transformed value which type same as `Collection.Element`.
    /// - Returns: The final result. If the collection has no elements, the result is `collection`.
    @inlinable
    @discardableResult
    public func map<C>(
        into collection: inout C, transform: (Element) throws -> C.Element
    ) rethrows -> C where C: RangeReplaceableCollection {
        for element in self {
            collection.append(try transform(element))
        }
        return collection
    }

    /// Returns an array containing the concatenated results of calling the given transformation with
    /// each element of this collection.
    ///
    /// - Parameter transform: A closure that accepts an element of this collection and the index of an element,
    /// returns a sequence or collection.
    /// - Returns: The resulting flattened array.
    @inlinable
    public func flatMapIndexed<SegmentOfResult>(
        _ transform: (Element, Index) throws -> SegmentOfResult
    ) rethrows -> [SegmentOfResult.Element] where SegmentOfResult: Sequence {
        if isEmpty {
            return []
        }
        var result: [SegmentOfResult.Element] = []
        var i = startIndex
        repeat {
            let t = try transform(self[i], i)
            result.append(contentsOf: t)
            i = index(after: i)
        } while i < endIndex
        return result
    }

    /// Returns the result of combining the elements of the collection using the given closure.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value. `initialResult` is passed
    /// to `nextPartialResult` the first time the closure is executed.
    ///   - nextPartialResult: A closure that combines an accumulating value and an element of the collection
    /// into a new accumulating value, to be used in the next call of the `nextPartialResult` closure or
    /// returned to the caller.
    /// - Returns: The final accumulated value. If the collection has no elements, the result is `initialResult`.
    @inlinable
    public func reduceIndexed<Result>(_ initialResult: Result,
        _ nextPartialResult: (Result, Element, Index) throws -> Result) rethrows -> Result {
        if isEmpty {
            return initialResult
        }
        var result = initialResult
        var i = startIndex
        repeat {
            result = try nextPartialResult(result, self[i], i)
            i = index(after: i)
        } while i < endIndex
        return result
    }

    /// Returns the first non-null value produced by `transform` function being applied
    /// to elements of this collection in iteration order, or `nil` if no non-null value was produced.
    ///
    /// - Parameter transform: A mapping closure.
    /// - Returns: The first non-null result of the given closure. If all elements in the collection
    /// after transform is `nil`, returns `nil`.
    @inlinable
    public func firstOf<R>(_ transform: (Element) throws -> R?) rethrows -> R? {
        for item in self {
            if let result = try transform(item) {
                return result
            }
        }
        return nil
    }

    /// Calls the given closure on each element in the collection in the same order as a for-in loop.
    ///
    /// - Parameter body: A closure that takes an element of the collection and the index of an element.
    @inlinable
    public func forEachIndexed(_ body: (Element, Index) throws -> Void) rethrows {
        if isEmpty {
            return
        }
        var i = startIndex
        repeat {
            try body(self[i], i)
            i = index(after: i)
        } while i < endIndex
    }
}

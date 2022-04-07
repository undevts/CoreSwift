// MIT License
//
// Copyright (c) 2022 The Core Swift Project Authors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

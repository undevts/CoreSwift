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

/// A collection of useful functions.
public struct Function {
    private init() {
        // Do nothing.
    }

    /// A function that returns the parameter itself directly.
    @inlinable
    @inline(__always)
    public static func identity<T>(_ value: T) -> T {
        value
    }

    /// A function that returns the parameter as `Optional<T>`.
    @inlinable
    @inline(__always)
    public static func optional<T>(_ value: T) -> T? {
        value
    }

    /// A function eats anything, returns `Void`.
    @inlinable
    @inline(__always)
    public static func nothing(_ value: Any) {
        // Do nothing.
    }

    /// A function eats nothing, returns `Void`.
    @inlinable
    @inline(__always)
    public static func nothing() {
        // Do nothing.
    }

    // Returns true if the parameter is `true`.
    @inlinable
    @inline(__always)
    public static func truly(_ value: Bool) -> Bool {
        value
    }

    // Returns true if the parameter is `false`.
    @inlinable
    @inline(__always)
    public static func falsely(_ value: Bool) -> Bool {
        !value
    }

    /// Create a method that always ignores all parameters and returns the current parameter.
    @inlinable
    @inline(__always)
    public static func always<T, R>(_ value: T) -> (R) -> T {
        { _ in value }
    }
}

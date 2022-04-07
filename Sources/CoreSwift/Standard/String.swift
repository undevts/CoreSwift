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

import Foundation // For Data

extension String {
    /// Convert any property of any object to a String. Generally used to convert a property
    /// in a C structure into a String. In Swift, C arrays will convert to homogeneous tuples,
    /// like: (Int, Int, Int, Int, Int, Int), which is not very useful.
    ///
    /// For example, to get the name of the system `utsname.machine` can be written like this:
    /// ```swift
    /// var raw = utsname()
    /// uname(&raw)
    /// let name = String(raw, keyPath: \utsname.machine, count: Int(_SYS_NAMELEN))
    /// // name = "iPhone14,2"
    /// ```
    ///
    /// - Parameters:
    ///   - value: The object to be resolved, usually a C structure.
    ///   - keyPath: A KeyPath object for reading properties.
    ///   - count: The length of C string.
    public init?<T>(_ value: T, keyPath: PartialKeyPath<T>, count: Int) {
        guard let offset = MemoryLayout<T>.offset(of: keyPath) else {
            return nil
        }
        let result = withUnsafePointer(to: value) { (pointer: UnsafePointer<T>) -> String? in
            let raw: UnsafeRawPointer = UnsafeRawPointer(pointer).advanced(by: offset)
            let field: UnsafePointer<UInt8> = raw.assumingMemoryBound(to: UInt8.self)
            if field[count - 1] != 0 {
                let data = Data(bytes: raw, count: count)
                return String(data: data, encoding: .utf8)
            } else {
                return String(cString: field)
            }
        }
        if let result = result {
            self = result
        } else {
            return nil
        }
    }
}

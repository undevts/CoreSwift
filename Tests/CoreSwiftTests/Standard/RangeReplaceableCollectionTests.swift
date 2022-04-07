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

import XCTest
@testable import CoreSwift

final class RangeReplaceableCollectionTests: XCTestCase {
    func testReplace() {
        var array = [1, 9, 8]
        XCTAssertEqual(array.replaced(at: 1, with: 100), [1, 100, 8])
        array.replace(at: 1, with: 100)
        XCTAssertEqual(array, [1, 100, 8])

        XCTAssertEqual(array.replaced(at: 0, with: -1), [-1, 100, 8])
        array.replace(at: 0, with: 200)
        XCTAssertEqual(array, [200, 100, 8])
    }
}
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

final class CollectionTests: XCTestCase {
    func testChunked() {
        let array = ["h", "i", "l", "l", "o"]
        XCTAssertEqual(array.chunked(size: 2),
            [["h", "i"], ["l", "l"], ["o"]])

        XCTAssertEqual(array.chunked(size: 10),
            [["h", "i", "l", "l", "o"]])
    }

    func testIsNotEmpty() {
        XCTAssertTrue([1].isNotEmpty)
        let empty: [Int] = []
        XCTAssertFalse(empty.isNotEmpty)

        XCTAssertTrue("empty".isNotEmpty)
        XCTAssertFalse("".isNotEmpty)
    }

    func testAt() {
        let array = [1, 5, 9]
        XCTAssertNil(array.at(-1))
        XCTAssertNil(array.at(array.endIndex))
        XCTAssertEqual(array.at(0)!, 1)
        XCTAssertEqual(array.at(2)!, 9)
    }

    func testAtOr() {
        let array = [1, 5, 9]
        XCTAssertEqual(array.at(-1, or: -1), -1)
        XCTAssertEqual(array.at(array.endIndex, or: 1000), 1000)
        XCTAssertEqual(array.at(0)!, 1)
        XCTAssertEqual(array.at(2)!, 9)
    }

    func testFilterIndexed() {
        var array = [0, 1, 3, 2, 4, 5, 7, 8, 9, 6]
        array = array.filterIndexed { item, index in
            item == index
        }
        XCTAssertEqual(array, [0, 1, 4, 5])
    }

    func testMapIndexed() {
        var array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        array = array.mapIndexed { item, index in
            item + index
        }
        XCTAssertEqual(array, [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
    }

    func testMapInto() {
        let array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let result = array.map(into: [10]) { i in
            i + 1
        }
        XCTAssertEqual(result, [10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }

    func testReduceIndexed() {
        let array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        let result = array.reduceIndexed(100) { result, item, index in
            result - item - index
        }
        XCTAssertEqual(result, 10)
    }

    func testForEachIndexed() {
        let array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        var result = 0
        array.forEachIndexed { item, index in
            result += item + index
        }
        XCTAssertEqual(result, 90)
    }
}

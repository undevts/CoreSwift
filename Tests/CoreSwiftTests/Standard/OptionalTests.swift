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

class Foo {
    var _bar: String?
    var bar: String {
        _bar.withPresenting {
            String(Int.max, radix: 16)
        }
    }
}

final class OptionalTests: XCTestCase {
    func testIsSome() {
        let foo: String? = ""
        let bar: String? = nil
        XCTAssertTrue(foo.isSome)
        XCTAssertFalse(bar.isSome)
    }

    func testisNone() {
        let foo: String? = ""
        let bar: String? = nil
        XCTAssertFalse(foo.isNone)
        XCTAssertTrue(bar.isNone)
    }

    func testExpect() {
        let foobar: String? = "foobar"
        XCTAssertEqual(foobar.expect("Not nil"), "foobar")
    }

    func testIfPresent() {
        let foo: String? = ""
        let bar: String? = nil

        var a = 0
        foo.ifPresent { _ in
            a += 10
        }
        XCTAssertEqual(a, 10)
        bar.ifPresent { _ in
            a -= 10
        }
        XCTAssertEqual(a, 10)
    }

    func testWithPresenting() {
        var foo: String? = ""
        var bar: String? = nil

        let first = foo.withPresenting {
            "foobar"
        }
        let second = bar.withPresenting {
            "abc"
        }
        XCTAssertEqual(foo!, "")
        XCTAssertEqual(first, "")
        XCTAssertEqual(bar!, "abc")
        XCTAssertEqual(second, "abc")
    }

    func testUnwrap() {
        let foo: String? = ""
        let bar: String? = nil

        XCTAssertEqual(foo.unwrap(or: "012"), "")
        XCTAssertEqual(bar.unwrap(or: "xyz"), "xyz")

        XCTAssertEqual(foo.unwrap { "012" }, "")
        XCTAssertEqual(bar.unwrap { "xyz" }, "xyz")
    }

    func testIsNoneOrEmpty() {
        let foo: String? = ""
        let bar: String? = nil
        let foobar: String? = "foobar"

        XCTAssertTrue(foo.isNoneOrEmpty)
        XCTAssertTrue(bar.isNoneOrEmpty)
        XCTAssertFalse(foobar.isNoneOrEmpty)

        let array: [Int]? = []
        let array2: [Int]? = nil
        let array3: [Int]? = [100]

        XCTAssertTrue(array.isNoneOrEmpty)
        XCTAssertTrue(array2.isNoneOrEmpty)
        XCTAssertFalse(array3.isNoneOrEmpty)
    }
}
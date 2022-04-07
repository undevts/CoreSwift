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

enum FooError: Error, Equatable {
    case foo
    case bar
}

enum BarError: Error, Equatable {
    case foo
    case bar
}

final class ResultTests: XCTestCase {
    func testIsSuccess() {
        var result = Result<Int, FooError>.success(1)
        XCTAssertTrue(result.isSuccess)
        result = .failure(.bar)
        XCTAssertFalse(result.isSuccess)
    }

    func testIsFailure() {
        var result = Result<Int, FooError>.success(1)
        XCTAssertFalse(result.isFailure)
        result = .failure(.bar)
        XCTAssertTrue(result.isFailure)
    }

    func testSucceed() {
        var result = Result<Int, FooError>.success(1)
        XCTAssertEqual(result.succeed!, 1)
        result = .failure(.bar)
        XCTAssertNil(result.succeed)
    }

    func testFailed() {
        var result = Result<Int, FooError>.success(1)
        XCTAssertNil(result.failed)
        result = .failure(.bar)
        XCTAssertEqual(result.failed!, FooError.bar)
    }

    func testAnd() {
        var item = Result<Int, FooError>.success(1)
        var result = item.and(.success("123"))
        XCTAssertEqual(result, Result<String, FooError>.success("123"))

        result = item.and(.failure(.bar))
        XCTAssertEqual(result, Result<String, FooError>.failure(.bar))

        item = Result<Int, FooError>.failure(.bar)
        result = item.and(.success("123"))
        XCTAssertEqual(result, Result<String, FooError>.failure(.bar))

        result = item.and(.failure(.foo))
        XCTAssertEqual(result, Result<String, FooError>.failure(.bar))
    }

    func testOr() {
        var item = Result<Int, FooError>.success(1)
        var result = item.or(Result<Int, BarError>.success(123))
        XCTAssertEqual(result, Result<Int, BarError>.success(1))

        result = item.or(.failure(BarError.bar))
        XCTAssertEqual(result, Result<Int, BarError>.success(1))

        var result2 = item.or(.failure(FooError.bar))
        XCTAssertEqual(result2, Result<Int, FooError>.success(1))

        item = Result<Int, FooError>.failure(.bar)
        result = item.or(Result<Int, BarError>.success(999))
        XCTAssertEqual(result, Result<Int, BarError>.success(999))

        result = item.or(Result<Int, BarError>.failure(.foo))
        XCTAssertEqual(result, Result<Int, BarError>.failure(.foo))

        result2 = item.or(.failure(FooError.bar))
        XCTAssertEqual(result2, Result<Int, FooError>.failure(.bar))
    }
}
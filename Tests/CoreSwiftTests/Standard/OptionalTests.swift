import XCTest

#if DEBUG
@testable import CoreSwift
#else
import CoreSwift
#endif

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

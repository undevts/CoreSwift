import XCTest

#if DEBUG
@testable import CoreSwift
@testable import CoreFilesystem
#else
import CoreFilesystem
#endif

fileprivate typealias View = Path.ComponentView
fileprivate typealias Index = Path.Index

func toString(path: Path, index: Path.Index) -> String {
#if DEBUG
    let bytes = path.buffer[index.content...]
    return bytes.toString() ?? "<ERROR>"
#else
    return ""
#endif
}

final class PathComponentViewTests: XCTestCase {
    private let path: Path = "/foo/bar/path/is/empty/foobar.zip"
    
    private func check(expected: String, _ index: Index, line: UInt = #line) {
        XCTAssertEqual(toString(path: path, index: index), expected, line: line)
    }
    
    func testIndex() {
        let view = path.components
        XCTAssertEqual(view.count, 7)

        let distance = view.distance(from: view.startIndex, to: view.endIndex)
        XCTAssertEqual(distance, 7)

        var next = view[...]
        XCTAssertEqual(next.path.string, path.string)
        next = view[view.startIndex...]
        XCTAssertEqual(next.path.string, path.string)
        next = view[..<view.endIndex]
        XCTAssertEqual(next.path.string, path.string)
        next = view[view.startIndex..<view.endIndex]
        XCTAssertEqual(next.path.string, path.string)
        
        var i = view.startIndex
        XCTAssertEqual(view[i].string, "/")
        
        i = view.index(after: i)
        XCTAssertEqual(view[i].string, "foo")
        next = view[i..<view.endIndex]
        XCTAssertEqual(next.path.string, "foo/bar/path/is/empty/foobar.zip")
        
        i = view.index(after: i)
        XCTAssertEqual(view[i].string, "bar")
        next = view[i..<view.endIndex]
        XCTAssertEqual(next.path.string, "bar/path/is/empty/foobar.zip")
        
        i = view.index(after: i)
        XCTAssertEqual(view[i].string, "path")
        next = view[i..<view.endIndex]
        XCTAssertEqual(next.path.string, "path/is/empty/foobar.zip")
        
        i = view.index(after: i)
        XCTAssertEqual(view[i].string, "is")
        next = view[i..<view.endIndex]
        XCTAssertEqual(next.path.string, "is/empty/foobar.zip")
        
        i = view.index(after: i)
        XCTAssertEqual(view[i].string, "empty")
        next = view[i..<view.endIndex]
        XCTAssertEqual(next.path.string, "empty/foobar.zip")
        
        i = view.index(after: i)
        XCTAssertEqual(view[i].string, "foobar.zip")
        next = view[i..<view.endIndex]
        XCTAssertEqual(next.path.string, "foobar.zip")

        i = view.index(after: i)
        XCTAssertEqual(i, view.endIndex)
    }
    
    func testIndexAfter() throws {
#if DEBUG
        let view = path.components
        var i = view.startIndex
        check(expected: "/foo/bar/path/is/empty/foobar.zip", i)
        i = view.index(after: i)
        check(expected: "foo/bar/path/is/empty/foobar.zip", i)
        i = view.index(after: i)
        check(expected: "bar/path/is/empty/foobar.zip", i)
        i = view.index(after: i)
        check(expected: "path/is/empty/foobar.zip", i)
        i = view.index(after: i)
        check(expected: "is/empty/foobar.zip", i)
        i = view.index(after: i)
        check(expected: "empty/foobar.zip", i)
        i = view.index(after: i)
        check(expected: "foobar.zip", i)
        i = view.index(after: i)
        check(expected: "", i)
        i = view.index(after: i)
        check(expected: "", i)
#else
        throw XCTSkip("Only support testable versions.")
#endif
    }

    func testIndexBefore() throws {
#if DEBUG
        let view = path.components
        var i = view.endIndex
        check(expected: "", i)
        i = view.index(before: i)
        check(expected: "foobar.zip", i)
        i = view.index(before: i)
        check(expected: "empty/foobar.zip", i)
        i = view.index(before: i)
        check(expected: "is/empty/foobar.zip", i)
        i = view.index(before: i)
        check(expected: "path/is/empty/foobar.zip", i)
        i = view.index(before: i)
        check(expected: "bar/path/is/empty/foobar.zip", i)
        i = view.index(before: i)
        check(expected: "foo/bar/path/is/empty/foobar.zip", i)
        i = view.index(before: i)
        check(expected: "/foo/bar/path/is/empty/foobar.zip", i)
        i = view.index(before: i)
        check(expected: "/foo/bar/path/is/empty/foobar.zip", i)
#else
        throw XCTSkip("Only support testable versions.")
#endif
    }

    func testIndexMatchCount() throws {
        func check(_ path: Path, count: Int, line: UInt = #line) {
            let view = path.components
            XCTAssertEqual(view.count, count, "count", line: line)
            XCTAssertEqual(view.distance(from: view.startIndex, to: view.endIndex), count, "index", line: line)
            var c = 0
            var i = view.startIndex
            var n = view.endIndex
            while i < n {
                i = view.index(after: i)
                c += 1
            }
            XCTAssertEqual(i, n, "n1", line: line)
            XCTAssertEqual(c, count, "c1", line: line)

            i = view.endIndex
            n = view.startIndex
            c = 0
            while n < i {
                i = view.index(before: i)
                c += 1
            }
            XCTAssertEqual(i, n, "n2", line: line)
            XCTAssertEqual(c, count, "c2", line: line)
        }

        check("///foo//", count: 2)
        check("/./foo//", count: 2)
        check("./.", count: 1)
    }
}

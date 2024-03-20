import XCTest

#if DEBUG
@testable import CoreFilesystem
#else
import CoreFilesystem
#endif

func reversedComponents(_ path: Path) -> [Path.Component] {
    var iterator = path.components.makeBackIterator()
    var result: [Path.Component] = []
    while let next = iterator.next() {
        result.append(next)
    }
    return result
}

final class PathTests: XCTestCase {
    func testComponents() {
        func check(_ path: Path, _ components: [String], hasRoot: Bool, isAbsolute: Bool,
            parent: String?, filename: String?, stem: String?, `extension`: String?,
            prefix: Path.Prefix?, line: UInt = #line) {
            // Forward iteration
            let array = path.components.map(\.string)
            XCTAssertEqual(array, components, line: line)

            // Reverse iteration
            let reversed = reversedComponents(path).map(\.string)
            XCTAssertEqual(reversed, components.reversed(), line: line)

            XCTAssertEqual(path.hasRoot, hasRoot, "hasRoot", line: line)
            XCTAssertEqual(path.isAbsolute, isAbsolute, "isAbsolute", line: line)

            XCTAssertEqual(path.parent()?.string, parent, "parent", line: line)

            XCTAssertEqual(path.filename?.string, filename, "filename", line: line)
            XCTAssertEqual(path.stem, stem, "stem", line: line)
            XCTAssertEqual(path.extension, `extension`, "extension", line: line)
        }

        check("", [],
            hasRoot: false, isAbsolute: false, parent: nil,
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("/", ["/"],
            hasRoot: true, isAbsolute: true, parent: nil,
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("foo", ["foo"],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: "foo", stem: "foo", extension: nil, prefix: nil)
        check("/foo", ["/", "foo"],
            hasRoot: true, isAbsolute: true, parent: "/",
            filename: "foo", stem: "foo", extension: nil, prefix: nil)
        check("foo/", ["foo"],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: "foo", stem: "foo", extension: nil, prefix: nil)
        check("/foo/", ["/", "foo"],
            hasRoot: true, isAbsolute: true, parent: "/",
            filename: "foo", stem: "foo", extension: nil, prefix: nil)

        check("foo/bar", ["foo", "bar"],
            hasRoot: false, isAbsolute: false, parent: "foo",
            filename: "bar", stem: "bar", extension: nil, prefix: nil)
        check("/foo/bar", ["/", "foo", "bar"],
            hasRoot: true, isAbsolute: true, parent: "/foo",
            filename: "bar", stem: "bar", extension: nil, prefix: nil)
        check("///foo///", ["/", "foo"],
            hasRoot: true, isAbsolute: true, parent: "/",
            filename: "foo", stem: "foo", extension: nil, prefix: nil)
        check("///foo///bar", ["/", "foo", "bar"],
            hasRoot: true, isAbsolute: true, parent: "///foo",
            filename: "bar", stem: "bar", extension: nil, prefix: nil)

        check("./.", ["."],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("/..", ["/", ".."],
            hasRoot: true, isAbsolute: true, parent: "/",
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("../", [".."],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: nil, stem: nil, extension: nil, prefix: nil)

        check("foo/.", ["foo"],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: "foo", stem: "foo", extension: nil, prefix: nil)
        check("foo/..", ["foo", ".."],
            hasRoot: false, isAbsolute: false, parent: "foo",
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("foo/./", ["foo"],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: "foo", stem: "foo", extension: nil, prefix: nil)
        check("foo/./bar", ["foo", "bar"],
            hasRoot: false, isAbsolute: false, parent: "foo",
            filename: "bar", stem: "bar", extension: nil, prefix: nil)
        check("foo/../", ["foo", ".."],
            hasRoot: false, isAbsolute: false, parent: "foo",
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("foo/../bar", ["foo", "..", "bar"],
            hasRoot: false, isAbsolute: false, parent: "foo/..",
            filename: "bar", stem: "bar", extension: nil, prefix: nil)

        check("./a", [".", "a"],
            hasRoot: false, isAbsolute: false, parent: ".",
            filename: "a", stem: "a", extension: nil, prefix: nil)
        check(".", ["."],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("./", ["."],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: nil, stem: nil, extension: nil, prefix: nil)
        check("a/b", ["a", "b"],
            hasRoot: false, isAbsolute: false, parent: "a",
            filename: "b", stem: "b", extension: nil, prefix: nil)
        check("a//b", ["a", "b"],
            hasRoot: false, isAbsolute: false, parent: "a",
            filename: "b", stem: "b", extension: nil, prefix: nil)
        check("a/./b", ["a", "b"],
            hasRoot: false, isAbsolute: false, parent: "a",
            filename: "b", stem: "b", extension: nil, prefix: nil)
        check("a/b/c", ["a", "b", "c"],
            hasRoot: false, isAbsolute: false, parent: "a/b",
            filename: "c", stem: "c", extension: nil, prefix: nil)

        check(".foo", [".foo"],
            hasRoot: false, isAbsolute: false, parent: "",
            filename: ".foo", stem: ".foo", extension: nil, prefix: nil)
        check("a/.foo", ["a", ".foo"],
            hasRoot: false, isAbsolute: false, parent: "a",
            filename: ".foo", stem: ".foo", extension: nil, prefix: nil)

        check("a/.foo.bar", ["a", ".foo.bar"],
            hasRoot: false, isAbsolute: false, parent: "a",
            filename: ".foo.bar", stem: ".foo", extension: "bar", prefix: nil)
        check("a/.x.y.z", ["a", ".x.y.z"],
            hasRoot: false, isAbsolute: false, parent: "a",
            filename: ".x.y.z", stem: ".x.y", extension: "z", prefix: nil)
    }

    func testFilename() {
        func check(_ path: Path, _ expect: String?, line: UInt = #line) {
            XCTAssertEqual(path.filename?.string, expect, line: line)
        }

        check("", nil)
        check("foo", "foo")
        check(".foo", ".foo")
        check("..", nil)
        check(".foo.", ".foo.")
        check("foo.swift", "foo.swift")
        check("foo.tar.gz", "foo.tar.gz")
    }

    func testExtension() {
        func check(_ path: Path, _ expect: String?, line: UInt = #line) {
            XCTAssertEqual(path.extension, expect, line: line)
        }

        check("", nil)
        check("foo", nil)
        check(".foo", nil)
        check("..", nil)
        check(".foo.", "")
        check("foo.swift", "swift")
        check("foo.tar.gz", "gz")
    }

    func testAppend() {
        let root: Path = "/usr/local/bin"

        func check(_ expect: String, _ path: (inout Path) -> Void,
            line: UInt = #line) {
            var temp = root
            path(&temp)
            XCTAssertEqual(temp.string, expect, line: line)
        }

        check("/usr/local/bin/git") { temp in
            temp.append("git")
        }

        check("/usr/local/bin/swift") { temp in
            let last = Path("/usr/bin/swift").lastComponent!
            temp.append(last)
        }

        check("/usr/local/bin/git") { temp in
            let bin = "git"
            temp.append(bin[bin.startIndex...])
        }
    }

    func testRelative() {
        func check(_ expect: String, _ path: () -> Path,
            line: UInt = #line) {
            XCTAssertEqual(path().string, expect, line: line)
        }

        check("../../impl/bbb") {
            Path.relative(from: "/data/orandea/test/aaa", to: "/data/orandea/impl/bbb")
        }

        check("../bbb") {
            Path.relative(from: "/data/orandea/test/aaa", to: "/data/orandea/test/bbb")
        }

        check("..") {
            Path.relative(from: "/data/orandea/test/aaa", to: "/data/orandea/test")
        }
    }
}

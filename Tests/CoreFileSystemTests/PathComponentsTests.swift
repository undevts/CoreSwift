import XCTest

#if DEBUG
@testable import CoreSwift
@testable import CoreFilesystem
#else
import CoreFilesystem
#endif

fileprivate typealias Components = Path.Components

final class PathComponentsTests: XCTestCase {
    func testNextComponent() throws {
#if DEBUG
        func check(_ path: Path, _ steps: [(Int, Int, Int, Path.ParseState, String?)],
            _ reversedSteps: [(Int, Int, Int, Path.ParseState, String?)],line: UInt = #line) {
            let bytes = path.buffer
            let s = bytes.startIndex
            var c = Components(path.components, current: s, front: .prefix, back: .body)

            func check(_ next: Path.Index, _ start: Int, _ content: Int,
                _ end: Int, _ state: Path.ParseState, _ string: String?, line: UInt) {
                XCTAssertEqual(next.start - s, start, "start", line: line)
                XCTAssertEqual(next.content - s, content, "content", line: line)
                XCTAssertEqual(next.end - s, end, "end", line: line)
                XCTAssertEqual(next.state, state, "state", line: line)
                XCTAssertEqual(bytes[next.content..<next.end].toString(), string, "string", line: line)
            }

            var _line = line + 1
            for step in steps {
                let next = c.nextIndex()
                check(next, step.0, step.1, step.2, step.3, step.4, line: _line)
                _line += 1
            }

            c = Components(path.components, current: bytes.endIndex, front: .prefix, back: .body)
            _line = line + UInt(steps.count) * 2 + 1
            for step in reversedSteps.reversed() {
                let previous = c.previousIndex()
                check(previous, step.0, step.1, step.2, step.3, step.4, line: _line)
                _line -= 1
            }
        }

        check("/usr/bin/swift", [
            (0, 0, 1, .startDirectory, "/"),
            (1, 1, 5, .body, "usr/"),
            (5, 5, 9, .body, "bin/"),
            (9, 9, 14, .body, "swift"),
            (14, 14, 14, .done, ""),
        ], [
            (0, 0, 0, .done, ""),
            (0, 0, 1, .startDirectory, "/"),
            (1, 1, 4, .body, "usr"),
            (4, 5, 8, .body, "bin"),
            (8, 9, 14, .body, "swift"),
        ])
        check("/usr/bin/swift/", [
            (0, 0, 1, .startDirectory, "/"),
            (1, 1, 5, .body, "usr/"),
            (5, 5, 9, .body, "bin/"),
            (9, 9, 15, .body, "swift/"),
            (15, 15, 15, .done, ""),
        ], [
            (0, 0, 0, .done, ""),
            (0, 0, 1, .startDirectory, "/"),
            (1, 1, 4, .body, "usr"),
            (4, 5, 8, .body, "bin"),
            (8, 9, 15, .body, "swift/"),
        ])
        check("./.", [
            (0, 0, 1, .startDirectory, "."),
            (1, 1, 3, .done, "/."),
        ], [
            (0, 0, 0, .done, ""),
            (0, 0, 1, .startDirectory, "."),
        ])
        check("///foo//", [
            (0, 0, 1, .startDirectory, "/"),
            (1, 3, 7, .body, "foo/"),
            (7, 7, 8, .done, "/"),
        ], [
            (0, 0, 0, .done, ""),
            (0, 0, 1, .startDirectory, "/"),
            (2, 3, 8, .body, "foo//"),
        ])
        check("/./foo//", [
            (0, 0, 1, .startDirectory, "/"),
            (1, 3, 7, .body, "foo/"),
            (7, 7, 8, .done, "/"),
        ], [
            (0, 0, 0, .done, ""),
            (0, 0, 1, .startDirectory, "/"),
            (2, 3, 8, .body, "foo//"),
        ])
#else
        throw XCTSkip("Only support testable versions.")
#endif
    }
}

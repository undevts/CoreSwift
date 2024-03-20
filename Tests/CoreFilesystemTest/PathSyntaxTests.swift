import XCTest
import CoreFilesystem

final class PathSyntaxTests: XCTestCase {
    func check(_ path: Path, components: [String], line: UInt = #line) {
        let view =  path.components.map(\.string)
        XCTAssertEqual(view, components, line: line)
    }
    
    func testPaths() {
        check("", components: [])
        check("/", components: ["/"])
        check("/..", components: ["/", ".."])
        check("/.", components: ["/", "."])
        check("/../.", components: ["/", "..", "."])
    }
}

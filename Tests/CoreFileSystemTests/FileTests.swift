import XCTest
import CoreSwift

#if DEBUG
@testable import CoreFilesystem
#else
import CoreFilesystem
#endif

final class FileTests: XCTestCase {
//    func testRead() throws {
//        let file: File = try File.open(#file).get()
//        var buffer = Bytes(exactlyCapacity: 13)
//        let size = try file.read(buffer: &buffer).get()
//        XCTAssertEqual(size, 13)
//        XCTAssertEqual(buffer.toString(), "import XCTest")
//    }

//    func testReadToEnd() throws {
//        let file: File = try File.open("/Users/yangnan/Desktop/foo.txt").get()
//        var buffer = Bytes(exactlyCapacity: 10)
//        let size = try file.read(into: &buffer).get()
//        XCTAssertEqual(size, 10)
//        print(buffer.description)
//    }
}

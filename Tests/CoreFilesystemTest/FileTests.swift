import XCTest
import CoreSwift

#if DEBUG
@testable import CoreFilesystem
#else
import CoreFilesystem
#endif

final class FileTests: XCTestCase {
    func read() throws {
        let file = try File.open("foo.txt").get()
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 10)
        let n = try file.read(buffer: buffer).get()
        print(buffer[..<n])
    }

    func testRead2() throws {
        let file = try File.open(#file).get()
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 10)
        let n = try file.read(buffer: buffer).get()
        print(buffer[..<n])
    }

    func testRead() throws {
        let file: File = try File.open(#file).get()
        var buffer = Bytes(exactlyCapacity: 13)
        let size = try file.read(buffer: &buffer).get()
        XCTAssertEqual(size, 13)
        XCTAssertEqual(buffer.toString(), "import XCTest")
    }

//    func testReadToEnd() throws {
//        let file: File = try File.open("/Users/yangnan/Desktop/foo.txt").get()
//        var buffer = Bytes(exactlyCapacity: 10)
//        let size = try file.read(into: &buffer).get()
//        XCTAssertEqual(size, 10)
//        print(buffer.description)
//    }
}

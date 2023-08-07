import XCTest

#if DEBUG
@testable import CoreSwift
#else
import CoreSwift
#endif

final class BytesTests: XCTestCase {
    func testCopyToContiguousArray() {
        let bytes = Bytes([1, 2, 3, 4])
        let array = bytes._copyToContiguousArray()
        XCTAssertEqual(array.count, 4)
    }

    func testRemove() {
        var bytes = Bytes([1, 2, 3, 4])
        XCTAssertEqual(bytes.remove(at: 2), 3)
        XCTAssertEqual(bytes.remove(at: 2), 4)
        XCTAssertEqual(bytes.count, 2)
        XCTAssertEqual(bytes.remove(at: 0), 1)
        XCTAssertEqual(bytes.remove(at: 0), 2)
        XCTAssertEqual(bytes.count, 0)
    }

    func testRemoveAll() {
        var bytes = Bytes([1, 2, 3, 4])
        let capacity = bytes.capacity
        bytes.removeAll(keepingCapacity: true)
        XCTAssertEqual(bytes.capacity, capacity)
        bytes.removeAll(keepingCapacity: false)
        XCTAssertEqual(bytes.capacity, 0)
    }

    func testFor() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        measure {
            for _ in 0..<100000 {
                let bytes = Bytes(capacity: 4096)
                for byte in bytes {
                    _ = byte
                }
            }
        }
#endif // DEBUG
    }

    func testForArray() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        measure {
            for _ in 0..<100000 {
                let array = Array<UInt8>(repeating: 0, count: 4096)
                for byte in array {
                    _ = byte
                }
            }
        }
#endif // DEBUG
    }

    func testForFromString() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        let bytes = Bytes("Performance tests should run in release mode.")
        measure {
            for _ in 0..<100000 {
                for byte in bytes {
                    _ = byte
                }
            }
        }
#endif // DEBUG
    }

    func testForString() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        let string = "Performance tests should run in release mode."
        measure {
            for _ in 0..<100000 {
                for byte in string.utf8 {
                    _ = byte
                }
            }
        }
#endif // DEBUG
    }


    func testAppendBytes() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        measure {
            var bytes = Bytes(capacity: 409600)
            let next = Bytes("test")
            for _ in 0..<100000 {
                bytes.append(next)
            }
        }
#endif // DEBUG
    }

    func testAppendString() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        var string = ""
        measure {
            for _ in 0..<100000 {
                string += "test"
            }
        }
#endif // DEBUG
    }
}

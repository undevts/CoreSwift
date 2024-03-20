#if swift(>=5.9)
import XCTest
import CoreSwift

final class FormatTests: XCTestCase {
    func testFormatInt() {
        let result = Format.format("", 123, 456)
        XCTAssertEqual(result, "123456")
    }
    
    func testFormatIntPerformance() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        var value = Int(Int32.max)
        measure {
            for _ in 0..<100000 {
                _ = Format.format("", value, value, value)
                value -= 1
            }
        }
#endif // DEBUG
    }
    
    func testFormatIntPerformanceSwift() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        var value = Int(Int32.max)
        measure {
            for _ in 0..<100000 {
                _ = "\(value)\(value)\(value)"
                value -= 1
            }
        }
#endif // DEBUG
    }
}
#endif // swift(>=5.9)

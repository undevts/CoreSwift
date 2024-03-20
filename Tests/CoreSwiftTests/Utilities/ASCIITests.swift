import XCTest

#if DEBUG
@testable import CoreSwift
#else
import CoreSwift
#endif

final class ASCIITests: XCTestCase {
    func testCompare() {
        XCTAssertEqual(ASCII.lowLine, ASCII.lowLine)
        XCTAssertLessThan(ASCII(0x41), ASCII(0x42))
        XCTAssertGreaterThan(ASCII(0x43), ASCII(0x42))
        XCTAssert(ASCII.lowLine == 0x5F)
        XCTAssert(0x5F == ASCII.lowLine)
    }

    func testSwitch() {
        let buffer = [ASCII.lineFeed, ASCII.carriageReturn]
        var i = buffer.makeIterator()
        switch (i.next(), i.next()) {
        case (.some(ASCII.lineFeed), .some(ASCII.carriageReturn)):
            break
        default:
            XCTFail("not match")
            return
        }
    }

    func testSwitchUInt8() {
        let buffer = [ASCII.lineFeed, ASCII.carriageReturn]
        var i = buffer.makeIterator()
        switch (i.next(), i.next()) {
        case (.some(0x0A), .some(0x0D)):
            break
        default:
            XCTFail("not match")
            return
        }
    }
}

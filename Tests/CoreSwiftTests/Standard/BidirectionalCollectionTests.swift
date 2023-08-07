import XCTest

#if DEBUG
@testable import CoreSwift
#else
import CoreSwift
#endif

final class BidirectionalCollectionTests: XCTestCase {
    func testLastOf() {
        do {
            let array: [Int] = [1, 3, 4]
            let first = array.lastOf { $0 == 3 ? 999 : nil }
            XCTAssertEqual(first!, 999)
        }
        do {
            let array: [Double] = [1.2, 3.0, 4.4, 5.0]
            let first = array.lastOf { Int(exactly: $0) }
            XCTAssertEqual(first!, 5)
        }
        do {
            let range = 1..<100
            let first = range.lastOf { $0 > 50 ? String($0) : nil }
            XCTAssertEqual(first!, "99")
        }
    }
}
